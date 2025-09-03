document.addEventListener('DOMContentLoaded', () => {
  const dock = document.querySelector('.dock');
  if (!dock) return;
  dock.querySelectorAll('button').forEach(btn => {
    btn.addEventListener('click', () => {
      dock.querySelectorAll('button').forEach(b => b.classList.remove('dock-active'));
      btn.classList.add('dock-active');
    });
  });
});