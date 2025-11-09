import "@hotwired/turbo-rails"
import "./controllers"

import "chartkick/highcharts"
import Highcharts from "highcharts"
window.Highcharts = Highcharts

import "./charts/sleep_chart"

// 新規予定作成モーダルのグローバル関数
document.addEventListener('DOMContentLoaded', function() {
  const newEventModal = document.getElementById('new_event_modal');
  const newEventForm = document.getElementById('new_event_form');

  if (!newEventModal || !newEventForm) return;

  // モーダルを閉じた時にシンプルモードにリセット
  newEventModal.addEventListener('close', function() {
    const simpleMode = document.getElementById('simple_mode');
    const detailMode = document.getElementById('detail_mode');

    if (!simpleMode || !detailMode) return;
    if (!simpleMode.classList.contains('hidden')) return;

    // シンプルモードに戻す
    detailMode.classList.add('hidden');
    simpleMode.classList.remove('hidden');

    newEventForm.querySelector('[name="start_date"]').setAttribute('required', 'required');
    newEventForm.querySelector('[name="start_time"]').setAttribute('required', 'required');
    newEventForm.querySelector('[name="end_time"]').setAttribute('required', 'required');
    newEventForm.querySelector('[name="start_date_detail"]').removeAttribute('required');
    newEventForm.querySelector('[name="start_time_detail"]').removeAttribute('required');
    newEventForm.querySelector('[name="end_time_detail"]').removeAttribute('required');
  });
});

// 新規予定作成モーダルを開く関数
window.openNewEventModal = function(date) {
  const form = document.getElementById('new_event_form');
  const modal = document.getElementById('new_event_modal');

  if (!form || !modal) return;

  // フォームをリセット
  form.reset();

  // シンプルモードに切り替え
  const simpleMode = document.getElementById('simple_mode');
  const detailMode = document.getElementById('detail_mode');

  if (detailMode && simpleMode) {
    detailMode.classList.add('hidden');
    simpleMode.classList.remove('hidden');
  }

  // 日付を設定
  const now = new Date();
  const currentHour = String(now.getHours()).padStart(2, '0');
  const currentMinute = String(now.getMinutes()).padStart(2, '0');
  const nextHour = String((now.getHours() + 1) % 24).padStart(2, '0');

  const startDateField = form.querySelector('[name="start_date"]');
  const startTimeField = form.querySelector('[name="start_time"]');
  const endTimeField = form.querySelector('[name="end_time"]');
  const startDateDetailField = form.querySelector('[name="start_date_detail"]');
  const startTimeDetailField = form.querySelector('[name="start_time_detail"]');
  const endDateField = form.querySelector('[name="end_date"]');
  const endTimeDetailField = form.querySelector('[name="end_time_detail"]');

  if (startDateField) startDateField.value = date;
  if (startTimeField) startTimeField.value = `${currentHour}:${currentMinute}`;
  if (endTimeField) endTimeField.value = `${nextHour}:${currentMinute}`;

  // 詳細モードのフィールドにも同じ値を設定（切り替え時のため）
  if (startDateDetailField) startDateDetailField.value = date;
  if (startTimeDetailField) startTimeDetailField.value = `${currentHour}:${currentMinute}`;
  if (endDateField) endDateField.value = date;
  if (endTimeDetailField) endTimeDetailField.value = `${nextHour}:${currentMinute}`;

  // required属性を設定
  if (startDateField) startDateField.setAttribute('required', 'required');
  if (startTimeField) startTimeField.setAttribute('required', 'required');
  if (endTimeField) endTimeField.setAttribute('required', 'required');
  if (startDateDetailField) startDateDetailField.removeAttribute('required');
  if (startTimeDetailField) startTimeDetailField.removeAttribute('required');
  if (endTimeDetailField) endTimeDetailField.removeAttribute('required');

  // モーダルを開く
  modal.showModal();
}

// シンプル/詳細モード切り替え
window.toggleDetailMode = function() {
  const simpleMode = document.getElementById('simple_mode');
  const detailMode = document.getElementById('detail_mode');
  const form = document.getElementById('new_event_form');

  if (!simpleMode || !detailMode || !form) return;

  if (detailMode.classList.contains('hidden')) {
    // 詳細モードに切り替え
    simpleMode.classList.add('hidden');
    detailMode.classList.remove('hidden');

    // シンプルモードの値を詳細モードにコピー
    const startDate = form.querySelector('[name="start_date"]').value;
    const startTime = form.querySelector('[name="start_time"]').value;
    const endTime = form.querySelector('[name="end_time"]').value;

    form.querySelector('[name="start_date_detail"]').value = startDate;
    form.querySelector('[name="start_time_detail"]').value = startTime;
    form.querySelector('[name="end_date"]').value = startDate;
    form.querySelector('[name="end_time_detail"]').value = endTime;

    // シンプルモードのフィールドを無効化
    form.querySelector('[name="start_date"]').removeAttribute('required');
    form.querySelector('[name="start_time"]').removeAttribute('required');
    form.querySelector('[name="end_time"]').removeAttribute('required');

    // 詳細モードのフィールドを有効化
    form.querySelector('[name="start_date_detail"]').setAttribute('required', 'required');
    form.querySelector('[name="start_time_detail"]').setAttribute('required', 'required');
    form.querySelector('[name="end_time_detail"]').setAttribute('required', 'required');
  } else {
    // シンプルモードに切り替え
    detailMode.classList.add('hidden');
    simpleMode.classList.remove('hidden');

    // 詳細モードの値をシンプルモードにコピー
    const startDate = form.querySelector('[name="start_date_detail"]').value;
    const startTime = form.querySelector('[name="start_time_detail"]').value;
    const endTime = form.querySelector('[name="end_time_detail"]').value;

    form.querySelector('[name="start_date"]').value = startDate;
    form.querySelector('[name="start_time"]').value = startTime;
    form.querySelector('[name="end_time"]').value = endTime;

    // 詳細モードのフィールドを無効化
    form.querySelector('[name="start_date_detail"]').removeAttribute('required');
    form.querySelector('[name="start_time_detail"]').removeAttribute('required');
    form.querySelector('[name="end_time_detail"]').removeAttribute('required');

    // シンプルモードのフィールドを有効化
    form.querySelector('[name="start_date"]').setAttribute('required', 'required');
    form.querySelector('[name="start_time"]').setAttribute('required', 'required');
    form.querySelector('[name="end_time"]').setAttribute('required', 'required');
  }
}