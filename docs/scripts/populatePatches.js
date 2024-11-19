async function populate() {
  const requestURL = '../assets/data/patches.json';

  try {
    const response = await fetch(requestURL, { cache: 'no-cache' });

    if (!response.ok) {
      throw new Error(`Network response was not ok: ${response.statusText}`);
    }

    const patches = await response.json();
    const { balance = [], game = [] } = patches; // Provide empty arrays as fallback

    if (balance.length === 0 && game.length === 0) {
      throw new Error('Invalid data format: Missing Balance or Game data.');
    }

    // Render only if data exists
    if (balance.length > 0) {
      renderPatchList(balance, '.BalanceJSONList');
    } else {
      console.warn('No balance data available.');
    }

    if (game.length > 0) {
      renderPatchList(game, '.GameJSONList');
    } else {
      console.warn('No game data available.');
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

  patchList.forEach(
    ({ patch = 'Unknown Patch', link = '#', date = 'Unknown Date' }) => {
      const listItem = document.createElement('li');

      const linkElement = document.createElement('a');
      linkElement.textContent = patch;
      linkElement.href = link;
      linkElement.target = '_blank';

      const dateElement = document.createElement('span');
      dateElement.textContent = date;

      listItem.append(linkElement, dateElement);
      fragment.appendChild(listItem);
    }
  );

  container.innerHTML = ''; // Clear any existing content
  container.appendChild(fragment); // Append all at once for better performance
}

document.addEventListener('DOMContentLoaded', populate);
