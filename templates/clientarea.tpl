<div class="text-left">
	<div class="row">
		<div class="col-12 col-md-6">
			<div class="row" style="margin-bottom: 12px">
				<small class="col-7"><strong>CPU</strong></small>
				<small id="vm_cpu_stat" class="col-5 text-right">...</small>
				<div class="col-12" style="margin-top: 8px">
					<div class="progress">
						<div id="vm_cpu_progress" class="progress-bar bg-info" role="progressbar" style="width: 0%"></div>
					</div>
				</div>
			</div>

			<div class="row" style="margin-bottom: 12px">
				<small class="col-7"><strong>RAM</strong></small>
				<small id="vm_ram_stat" class="col-5 text-right">...</small>
				<div class="col-12" style="margin-top: 8px">
					<div class="progress">
						<div id="vm_ram_progress" class="progress-bar bg-info" role="progressbar" style="width: 0%"></div>
					</div>
				</div>
			</div>

			<div class="row" style="margin-bottom: 12px">
				<small class="col-7"><strong>Дисковое пространство</strong></small>
				<small id="vm_disk_stat" class="col-5 text-right">...</small>
				<div class="col-12" style="margin-top: 8px">
					<div class="progress">
						<div id="vm_disk_progress" class="progress-bar bg-info" role="progressbar" style="width: 0%"></div>
					</div>
				</div>
			</div>
		</div>
		<div class="col-12 col-md-6">
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">IP-адрес</div>
				<div class="col-6 text-right text-monospace">{$dedicatedip}</div>
			</div>
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">Имя пользователя</div>
				<div class="col-6 text-right text-monospace">{$username}</div>
			</div>
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">Пароль</div>
				<div class="col-6 text-right text-monospace">{$password}</div>
			</div>
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">Статус</div>
				<div class="col-6 text-right">
					<span id="vm_state" class="label label-default">Загрузка...</span>
				</div>
			</div>
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">TUN/TAP</div>
				<div class="col-6 text-right">
					<span id="vm_tuntap">...</span>
				</div>
			</div>
			<div class="row" style="font-size: 15px; margin-bottom: 8px;">
				<div class="col-6">Nesting</div>
				<div class="col-6 text-right">
					<span id="vm_nesting">...</span>
				</div>
			</div>
		</div>
	</div>
	<button data-vm-state="stopped" onclick="startVm(this)" type="button" class="btn btn-success">
		<i class="fas fa-play"></i>
	</button>
	<button data-vm-state="running" onclick="stopVm(this)" type="button" class="btn btn-danger">
		<i class="fas fa-stop"></i>
	</button>
	<button data-vm-state="running" onclick="restartVm(this)" type="button" class="btn btn-warning">
		<i class="fas fa-redo"></i>
	</button>
	<button data-vm-status="active" onclick="openVmReinstall(this)" type="button" class="btn btn-default">Переустановить</button>
	<button data-vm-status="active" data-toggle="modal" data-target="#vm_tuntap_modal" id="vm_tuntap_btn" type="button" disabled class="btn btn-default">Вкл. TUN/TAP</button>
	<button data-vm-status="active" data-toggle="modal" data-target="#vm_nesting_modal" id="vm_nesting_btn" type="button" disabled class="btn btn-default">Вкл. Nesting</button>
</div>

<div class="modal fade" id="vm_tuntap_modal" tabindex="-1" aria-hidden="true">
	<div class="modal-dialog text-left">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Активация TUN/TAP</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body">
				Внимание! Для активации необходимо будет выполнить перезапуск Вашего сервера. Убедитесь, что Вы закрыли все важные приложения и сохранили все данные.
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Отмена</button>
				<button onclick="enableVmFeature('tuntap', this)" type="button" class="btn btn-danger">Запросить активацию</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="vm_nesting_modal" tabindex="-1" aria-hidden="true">
	<div class="modal-dialog text-left">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Активация Nesting</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body">
				Внимание! Для активации необходимо будет выполнить перезапуск Вашего сервера. Убедитесь, что Вы закрыли все важные приложения и сохранили все данные.
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Отмена</button>
				<button onclick="enableVmFeature('nesting', this)" type="button" class="btn btn-danger">Запросить активацию</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="vm_reinstall_modal" tabindex="-1" aria-hidden="true">
	<div class="modal-dialog text-left">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Переустановка ОС</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body">
				<div class="form-group">
					<label class="form-label">Новая ОС:</label>
					<select id="vm_reinstall_select" class="custom-select"></select>
				</div>
				<div class="form-group form-check">
					<input type="checkbox" class="form-check-input" id="vm_reinstall_confirm" />
					<label class="form-check-label" for="vm_reinstall_confirm">
						Я подтверждаю, что хочу запустить переустановку ОС, в процессе которой будут удалены все данные, хранящиеся на сервере.
					</label>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Отмена</button>
				<button onclick="reinstallOs(this)" type="button" class="btn btn-danger">Продолжить</button>
			</div>
		</div>
	</div>
</div>

<script>
const STATUS_COLORS = {
	order_processing: 'info',
	installation: 'info',
	active: 'success',
	expired: 'info',
	blocked: 'danger',
	paused: 'warning',
	running: 'success',
	stopped: 'danger'
};

const STATUS_LABELS = {
	order_processing: 'Обработка заказа',
	installation: 'Установка',
	active: 'Активен',
	expired: 'Не оплачен',
	blocked: 'Заблокирован',
	paused: 'Приостановлен',
	running: 'Запущен',
	stopped: 'Остановлен'
};

function getProgressColor (value) {
	if (value > 0.95) {
		return 'danger';
	} else if (value > 0.75) {
		return 'warning';
	} else {
		return 'success';
	}
}

function act (action, payload = {}) {
	const form = new FormData();
	form.append('mod_act', action);
	for (const key in payload) {
		form.append(key, payload[key]);
	}

	return fetch(location.href, {
		body: form,
		method: 'POST',
		mode: 'cors',
		credentials: 'include'
	})
	.then(res => res.json());
}


async function updateVmStats () {
	const res = await act('get_stats');

	$('[data-vm-state]').hide();
	$('[data-vm-state="' + res.state.status + '"]').show().removeAttr('disabled');

	$('[data-vm-status]').hide();
	$('[data-vm-status="' + res.status + '"]').show().removeAttr('disabled');

	vm_state.className = 'label label-' + STATUS_COLORS[res.status == 'active' ? res.state.status : res.status];
	vm_state.innerHTML = STATUS_LABELS[res.status == 'active' ? res.state.status : res.status];

	vm_cpu_progress.className = 'progress-bar bg-' + getProgressColor(res.state.cpu);
	vm_cpu_progress.style.width = res.state.cpu * 100 + '%';
	vm_cpu_stat.innerHTML = (res.state.cpu * 100).toFixed(2) + '% из ' + res.state.max_cpu + ' vCPU';

	vm_ram_progress.className = 'progress-bar bg-' + getProgressColor(res.state.ram);
	vm_ram_progress.style.width = res.state.ram * 100 + '%';
	vm_ram_stat.innerHTML = (res.state.ram * 100).toFixed(2) + '% из ' + res.state.max_ram + ' GB';

	vm_disk_progress.className = 'progress-bar bg-' + getProgressColor(res.state.disk);
	vm_disk_progress.style.width = res.state.disk * 100 + '%';
	vm_disk_stat.innerHTML = (res.state.disk * 100).toFixed(2) + '% из ' + res.state.max_disk + ' GB';

	vm_tuntap.innerHTML = res.tuntap_enabled ? 'Включен' : 'Отключен';
	vm_tuntap_btn.disabled = res.tuntap_enabled;
	vm_nesting.innerHTML = res.nesting_enabled ? 'Включен' : 'Отключен';
	vm_nesting_btn.disabled = res.nesting_enabled;
}

updateVmStats();
setInterval(updateVmStats, 5000);

$('[data-vm-state]').hide();
$('[data-vm-status]').hide();

async function startVm (btn) {
	btn.disabled = true;
	const res = await act('start');
	if (res != 'ok') {
		btn.disabled = false;
	}
}

async function stopVm (btn) {
	btn.disabled = true;
	const res = await act('stop');
	if (res != 'ok') {
		btn.disabled = false;
	}
}

async function restartVm (btn) {
	btn.disabled = true;
	const res = await act('restart');
	if (res != 'ok') {
		btn.disabled = false;
	}
}

async function enableVmFeature (feature, btn) {
	btn.disabled = true;
	const res = await act(feature);
	if (res != 'ok') {
		btn.disabled = false;
	} else {
		$('#vm_' + feature + '_modal').modal('hide');
		$('#vm_' + feature + '_btn').attr('disabled', true);
	}
}

async function openVmReinstall (btn) {
	btn.disabled = true;
	const res = await act('get_oses');
	btn.disabled = false;

	$('#vm_reinstall_modal').modal('show');
	$('#vm_reinstall_select').children().remove();

	for (const os of res) {
		const option = document.createElement('option');
		option.value = os.image;
		option.innerHTML = os.label;
		$('#vm_reinstall_select').append(option);
	}
}

async function reinstallOs (btn) {
	if (!$('#vm_reinstall_confirm').is(':checked')) {
		alert('Подтвердите переустановку');
		return;
	}

	btn.disabled = true;
	const res = await act('reinstall_os', { os: $('#vm_reinstall_select').val() });
	if (res != 'ok') {
		btn.disabled = false;
	} else {
		$('#vm_reinstall_modal').modal('hide');
	}
}
</script>