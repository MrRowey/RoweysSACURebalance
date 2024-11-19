async function populate() {
  const requestURL = './data/version.json';

  try {
    const response = await fetch(requestURL, { cache: 'no-cache' });

    if (!response.ok) {
      throw new Error(`Network response was not ok: ${response.statusText}`);
    }

    const patches = await response.json();
    const { version = [] } = patches; // Provide empty arrays as fallback

    if (version.length === 0) {
      throw new Error('Invalid data format: Missing Version data.');
    }

    // Render only if data exists
    if (version.length > 0) {
      renderPatchList(version, '.VersionJSONList');
    } else {
      console.warn('No balance data available.');
    }
  } catch (error) {
    console.error('There has been a problem with your fetch operation:', error);
  }
}

function renderPatchList(patchList, containerSelector) {
  const container = document.querySelector(containerSelector);

  if (!container) {
    console.error(`Container with selector "${containerSelector}" not found.`);
    return;
  }

  const fragment = document.createDocumentFragment(); // Use DocumentFragment for better performance

  patchList.forEach(({ patch = 'Unknown Patch', link = '#' }) => {
    const listItem = document.createElement('li');

    const linkElement = document.createElement('a');
    linkElement.textContent = patch;
    linkElement.href = link;
    linkElement.target = '_blank';

    listItem.append(linkElement);
    fragment.appendChild(listItem);
  });

  container.innerHTML = ''; // Clear any existing content
  container.appendChild(fragment); // Append all at once for better performance
}

document.addEventListener('DOMContentLoaded', populate);
