async function populate() {
  const requestURL = '../data/version.json';

  try {
    const response = await fetch(requestURL, { cache: 'no-cache' });

    if (!response.ok) {
      throw new Error(`Network response was not ok: ${response.statusText}`);
    }

    const data = await response.json();
    const { Version = [] } = data; // Extract Version array, default to empty array if missing

    if (Version.length === 0) {
      throw new Error('Invalid data format: Missing Version data.');
    }

    // Render the Version list
    renderVersionList(Version, '.VersionJSONList');
  } catch (error) {
    console.error('There has been a problem with your fetch operation:', error);
  }
}

function renderVersionList(versionList, containerSelector) {
  const container = document.querySelector(containerSelector);

  if (!container) {
    console.error(`Container with selector "${containerSelector}" not found.`);
    return;
  }

  const fragment = document.createDocumentFragment(); // Use DocumentFragment for better performance

  versionList.forEach(({ patch = 'Unknown Patch', link = '#' }) => {
    const listItem = document.createElement('li');

    const linkElement = document.createElement('a');
    linkElement.textContent = patch;
    linkElement.href = link;
    linkElement.target = '_blank';

    listItem.appendChild(linkElement);
    fragment.appendChild(listItem);
  });

  container.innerHTML = ''; // Clear any existing content
  container.appendChild(fragment); // Append all at once for better performance
}

document.addEventListener('DOMContentLoaded', populate);
