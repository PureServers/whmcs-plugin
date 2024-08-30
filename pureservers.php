<?php
if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

function pureservers_Post ($path, $payload, $headers = []) {
	$headers[] = 'Content-type: application/json';
	$req = stream_context_create([
		'http' => [
			'method' => 'POST',
			'header' => implode("\n", $headers),
			'content' => json_encode($payload),
			'ignore_errors' => true
		]
	]);

	$res = file_get_contents('https://cp.pureservers.org/api'.$path, false, $req);

	$code = 0;
	if(preg_match('#HTTP/[0-9\.]+\s+([0-9]+)#', $http_response_header[0], $match)) {
		$code = intval($match[1]);
	}

	unset($http_response_header[0]);

	return (object) [
		'success' => $code < 400,
		'message' => json_decode($res) ?? $res,
		'headers' => $http_response_header
	];
}

function pureservers_PostAuthed ($path, $payload, $params) {
	$authRes = pureservers_Post('/auth/login', [
		'email' => $params['configoption1'],
		'password' => $params['configoption2']
	]);

	if (!$authRes->success) {
		return $authRes;
	}

	$headers = [];
	foreach ($authRes->headers as $header) {
		if (strpos($header, 'session:') === 0) {
			$headers[] = $header;
			break;
		}
	}

	$res = pureservers_Post($path, $payload, $headers);
	pureservers_Post('/auth/logout', [], $headers);

	return $res;
}

function pureservers_MetaData () {
    return [
        'DisplayName' => 'PureServers',
		'APIVersion' => '1.1',
		'RequiresServer' => false
	];
}

function pureservers_ConfigOptions () {
	return [
		'email' => [
			'FriendlyName' => 'E-mail',
			'Type' => 'text',
			'SimpleMode' => true
		],
		'password' => [
			'FriendlyName' => 'Пароль',
			'Type' => 'password',
			'SimpleMode' => true
		],
		'planId' => [
			'FriendlyName' => 'Тариф PureServers',
			'Type' => 'dropdown',
            'Loader' => function () {
				$res = pureservers_Post('/public/tariffs', ['currency' => 'BYN']);
				if (!$res->success) {
					throw new Exception("Не удалось получить список тарифов. {$res->message}");
				}

				$list = [];
				foreach ($res->message as $tariff) {
					$list[$tariff->_id] = "{$tariff->visible_name}: {$tariff->cpu} vCPU, {$tariff->ram} GB ОЗУ, {$tariff->disk} GB диска за {$tariff->price} BYN";
				}

				return $list;
			},
			'SimpleMode' => true
		]
	];
}

function pureservers_CreateAccount ($params) {
	$orderRes = pureservers_PostAuthed('/servers/order', $params['configoption3'] /* planId */, $params);
	if (!$orderRes->success) {
		logModuleCall(
            'pureservers',
            'CreateAccount',
            'POST ./servers/order '.json_encode($params['configoption3']),
            'Не удалось заказать сервер: '.json_encode($orderRes->message),
			$orderRes->message,
			[]
        );

		return 'Не удалось заказать сервер. Обратитесь в поддержку.';
	}

	$listRes = pureservers_PostAuthed('/servers/list', [], $params);
	if ($listRes->success) {
		foreach ($listRes->message as $server) {
			if ($server->_id == $orderRes->message) {
				localAPI('UpdateClientProduct', [
					'serviceid' => $params['serviceid'],
					'dedicatedip' => $server->linked_ips[0]->ip,
					'serviceusername' => $server->username,
					'servicepassword' => $server->password,
					'customfields' => base64_encode(serialize([
						'pureServerId' => $server->_id
					]))
				]);

				break;
			}
		}
	}

	return 'success';
}

function pureservers_GetVpsStats ($params) {
	$listRes = pureservers_PostAuthed('/servers/list', [], $params);
	if ($listRes->success) {
		foreach ($listRes->message as $server) {
			if ($server->_id == $params['customfields']['pureServerId']) {
				return [
					'tuntap_enabled' => $server->tuntap_enabled,
					'nesting_enabled' => $server->nesting_enabled,
					'state' => $server->state,
					'status' => $server->status
				];
			}
		}
	}
}

function pureservers_ClientArea ($params) {
	if (isset($_POST['mod_act'])) {
		switch ($_POST['mod_act']) {
			case 'get_stats':
				echo json_encode(pureservers_GetVpsStats($params));
				exit;
			case 'get_oses':
				$res = pureservers_PostAuthed('/servers/get-reinstall-oses', $params['customfields']['pureServerId'], $params);
				echo json_encode($res->message);
				exit;
			case 'reinstall_os':
				$res = pureservers_PostAuthed('/servers/reinstall', ['server_id' => $params['customfields']['pureServerId'], 'os' => $_POST['os']], $params);
				if (!$res->success) {
					echo $res->message;
				} else {
					echo '"ok"';
				}
				exit;
			case 'start':
			case 'stop':
			case 'restart':
				pureservers_PostAuthed('/servers/'.$_POST['mod_act'], $params['customfields']['pureServerId'], $params);
				echo '"ok"';
				exit;
			case 'tuntap':
			case 'nesting':
				pureservers_PostAuthed('/servers/enable-feature', ['server_id' => $params['customfields']['pureServerId'], 'feature' => $_POST['mod_act']], $params);
				echo '"ok"';
				exit;
			default:
				echo 'Unknown action';
				exit;
		}
	}

    return [
        'templatefile' => 'clientarea',
        'vars' => []
	];
}

function pureservers_SuspendAccount ($params) {
	$res = pureservers_PostAuthed('/servers/stop', $params['customfields']['pureServerId'], $params);
	if (!$res->success) {
		return $res->message;
	} else {
		return 'success';
	}
}

function pureservers_Renew ($params) {
	$months = 0;
	switch ($params['model']['billingcycle']) {
		case 'Monthly':
			$months = 1;
			break;
		case 'Quarterly':
			$months = 3;
			break;
		case 'Semi-Annually':
			$months = 6;
			break;
		case 'Annually':
			$months = 12;
			break;
	}

	if ($months == 0) {
		return 'success';
	}

	$res = pureservers_PostAuthed('/servers/renew', ['server_id' => $params['customfields']['pureServerId'], 'period' => $months], $params);
	if (!$res->success) {
		return $res->message;
	} else {
		return 'success';
	}
}
