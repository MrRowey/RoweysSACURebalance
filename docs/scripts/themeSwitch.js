const THEME_KEY = 'theme';
const LIGHT_MODE_CLASS = 'light-mode';

function toggleTheme() {
  const htmlElement = document.documentElement;
  const isLightMode = htmlElement.classList.toggle(LIGHT_MODE_CLASS);
  const newTheme = isLightMode ? 'light' : 'dark';
  try {
    localStorage.setItem(THEME_KEY, newTheme);
  } catch (e) {
    console.warn('Unable to access localStorage. Theme will reset on reload.');
  }
}

function loadTheme() {
  const htmlElement = document.documentElement;
  let savedTheme;

  try {
    savedTheme = localStorage.getItem(THEME_KEY);
  } catch (e) {
    console.warn('Unable to access localStorage. Using default theme.');
  }

  if (savedTheme === 'light') {
    htmlElement.classList.add(LIGHT_MODE_CLASS);
  } else {
    htmlElement.classList.remove(LIGHT_MODE_CLASS);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  // Load the saved theme on page load
  loadTheme();

  const themeToggleButton = document.querySelector('#themeToggleButton');
  if (themeToggleButton) {
    themeToggleButton.addEventListener('click', toggleTheme);
  }
});
