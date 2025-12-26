// 削除処理
window.deleteSleepRecord = function() {
  if (!confirm('本当に削除しますか？')) {
    return;
  }

  const deleteForm = document.getElementById('sleep_record_delete_form');
  if (deleteForm) {
    deleteForm.submit();
  }
};

// 日付と時刻を結合してhiddenフィールドに設定
function updateWakeTimeHidden() {
  const date = document.getElementById('modal_wake_date').value;
  const time = document.getElementById('modal_wake_time_only').value;
  if (date && time) {
    document.getElementById('modal_wake_time').value = `${date}T${time}`;
  }
}

function updateBedTimeHidden() {
  const date = document.getElementById('modal_bed_date').value;
  const time = document.getElementById('modal_bed_time_only').value;
  if (date && time) {
    document.getElementById('modal_bed_time').value = `${date}T${time}`;
  } else {
    document.getElementById('modal_bed_time').value = '';
  }
}

window.openSleepRecordModal = function(mode, recordId = null, wakeTime = null, bedTime = null, date = null) {
  const modal = document.getElementById('sleep_record_modal');
  const form = document.getElementById('sleep_record_form');
  const title = document.getElementById('sleep_record_modal_title');
  const submitBtn = document.getElementById('sleep_record_submit_btn');
  const errorsDiv = document.getElementById('sleep_record_errors');
  const deleteBtn = document.getElementById('sleep_record_delete_btn');
  const deleteForm = document.getElementById('sleep_record_delete_form');
  const footer = document.getElementById('sleep_record_modal_footer');

  // エラー表示をクリア
  errorsDiv.classList.add('hidden');


  if (mode === 'new') {
    title.textContent = modal.dataset.titleNew;
    form.action = '/sleep_records';
    form.querySelector('input[name="_method"]')?.remove();
    submitBtn.value = modal.dataset.labelCreate;

    // 削除ボタンを非表示、フッターを右寄せ
    if (deleteBtn) {
      deleteBtn.classList.add('hidden');
    }
    if (deleteForm) {
      deleteForm.action = '';
    }
    if (footer) {
      footer.classList.remove('justify-between');
      footer.classList.add('justify-end');
    }

    // dateパラメータがある場合、起床時刻のデフォルト値を設定
    if (date) {
      const defaultDate = new Date(date);
      document.getElementById('modal_wake_date').value = date;
      document.getElementById('modal_wake_time_only').value = '07:00';
      updateWakeTimeHidden();

      // 就寝時刻は同日の22:00を初期値として設定
      document.getElementById('modal_bed_date').value = date;
      document.getElementById('modal_bed_time_only').value = '22:00';
      updateBedTimeHidden();
    } else {
      const now = new Date();
      document.getElementById('modal_wake_date').value = now.toISOString().split('T')[0];
      document.getElementById('modal_wake_time_only').value = now.toTimeString().slice(0, 5);
      updateWakeTimeHidden();

      // 就寝時刻は同日の22:00を初期値として設定
      const bedDateStr = now.toISOString().split('T')[0];
      document.getElementById('modal_bed_date').value = bedDateStr;
      document.getElementById('modal_bed_time_only').value = '22:00';
      updateBedTimeHidden();
    }
  } else if (mode === 'edit') {
    title.textContent = modal.dataset.titleEdit;
    form.action = `/sleep_records/${recordId}`;

    // PATCH methodを追加
    let methodInput = form.querySelector('input[name="_method"]');
    if (!methodInput) {
      methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      form.insertBefore(methodInput, form.firstChild);
    }
    methodInput.value = 'patch';

    submitBtn.value = modal.dataset.labelUpdate;

    // 削除ボタンを表示して、削除フォームのactionを設定、フッターを左右配置
    if (deleteBtn) {
      deleteBtn.classList.remove('hidden');
    }
    if (deleteForm) {
      deleteForm.action = `/sleep_records/${recordId}`;
    }
    if (footer) {
      footer.classList.remove('justify-end');
      footer.classList.add('justify-between');
    }

    // 起床時刻を分離
    if (wakeTime) {
      const [wakeDate, wakeTimeOnly] = wakeTime.split('T');
      document.getElementById('modal_wake_date').value = wakeDate;
      document.getElementById('modal_wake_time_only').value = wakeTimeOnly;
      document.getElementById('modal_wake_time').value = wakeTime;
    }

    // 就寝時刻を分離
    if (bedTime) {
      const [bedDate, bedTimeOnly] = bedTime.split('T');
      document.getElementById('modal_bed_date').value = bedDate;
      document.getElementById('modal_bed_time_only').value = bedTimeOnly;
      document.getElementById('modal_bed_time').value = bedTime;
    } else {
      document.getElementById('modal_bed_date').value = '';
      document.getElementById('modal_bed_time_only').value = '';
      document.getElementById('modal_bed_time').value = '';
    }
  }

  modal.showModal();
};

// フォーム送信時の処理
function setupSleepRecordForm() {
  // 日付・時刻フィールドの変更を監視
  const wakeDate = document.getElementById('modal_wake_date');
  const wakeTimeOnly = document.getElementById('modal_wake_time_only');
  const bedDate = document.getElementById('modal_bed_date');
  const bedTimeOnly = document.getElementById('modal_bed_time_only');

  if (wakeDate && wakeTimeOnly) {
    wakeDate.addEventListener('change', updateWakeTimeHidden);
    wakeTimeOnly.addEventListener('change', updateWakeTimeHidden);
  }

  if (bedDate && bedTimeOnly) {
    bedDate.addEventListener('change', updateBedTimeHidden);
    bedTimeOnly.addEventListener('change', updateBedTimeHidden);
  }

  const form = document.getElementById('sleep_record_form');
  if (form && !form.dataset.initialized) {
    form.dataset.initialized = 'true';

    form.addEventListener('submit', function() {
      // 送信前に最新の値を更新
      updateWakeTimeHidden();
      updateBedTimeHidden();
    });
  }
}

// DOMContentLoaded と Turbo load イベントで初期化
if (document.readyState !== 'loading') {
  setupSleepRecordForm();
} else {
  document.addEventListener('DOMContentLoaded', setupSleepRecordForm);
}

// Turbo による画面遷移後の初期化
document.addEventListener('turbo:load', setupSleepRecordForm);
