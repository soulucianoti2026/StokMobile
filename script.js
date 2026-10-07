'use strict';
(() => {
  document.documentElement.classList.add('js');
  const config = window.STOKMOBILE_CONFIG || {};
  const menu = document.querySelector('.menu-toggle');
  const navigation = document.querySelector('.navigation-links');
  const dialog = document.querySelector('#info-dialog');
  const title = document.querySelector('#dialog-title');
  const content = document.querySelector('#dialog-content');
  let previousFocus;

  function setMenu(open) {
    menu.setAttribute('aria-expanded', String(open));
    navigation.classList.toggle('is-open', open);
  }
  menu.addEventListener('click', () => setMenu(menu.getAttribute('aria-expanded') !== 'true'));
  navigation.addEventListener('click', event => {
    if (event.target.closest('a')) setMenu(false);
  });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menu.getAttribute('aria-expanded') === 'true') {
      setMenu(false);
      menu.focus();
    }
  });
  function paragraph(text) {
    const element = document.createElement('p');
    element.textContent = text;
    content.append(element);
  }
  function showDialog(heading, text) {
    previousFocus = document.activeElement;
    title.textContent = heading;
    content.replaceChildren();
    paragraph(text);
    dialog.showModal();
  }
  function closeDialog() { dialog.close(); }
  dialog.querySelector('.dialog-close').addEventListener('click', closeDialog);
  dialog.addEventListener('click', event => {
    const rect = dialog.getBoundingClientRect();
    if (event.target === dialog && (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom)) closeDialog();
  });
  dialog.addEventListener('close', () => {
    content.querySelector('video')?.pause();
    previousFocus?.focus();
  });
  function officialUrl(key) {
    if (!config[key]) return null;
    try {
      const url = new URL(config[key]);
      return url.protocol === 'https:' ? url.href : null;
    } catch { return null; }
  }
  function visitOrExplain(key, heading, message) {
    const url = officialUrl(key);
    if (url) window.location.assign(url);
    else showDialog(heading, message);
  }
  document.querySelectorAll('[data-store]').forEach(button => {
    button.addEventListener('click', () => visitOrExplain(button.dataset.store, 'O StokMobile está chegando', 'O aplicativo ainda não está disponível para download por este site. Acompanhe as novidades ou fale com nossa equipe pelo e-mail suporte@stokmobile.com.br.'));
  });
  const features = [
    ['Estoque em tempo real', 'Consulte quantidades, valor do estoque e disponibilidade dos produtos em um painel que reúne as informações da operação.'],
    ['Entrada e saída', 'Registre o produto e a quantidade de cada entrada ou saída para acompanhar as movimentações do estoque.'],
    ['Histórico completo', 'Acompanhe quem realizou cada movimentação, quando ela aconteceu e qual quantidade foi registrada.'],
    ['Alertas inteligentes', 'Compare o saldo dos produtos com o estoque mínimo e identifique os itens que precisam de reposição.'],
    ['Busca rápida', 'Localize os produtos por nome, código ou categoria para consultar suas informações.'],
    ['Mobilidade de verdade', 'Consulte as informações da operação no depósito, na loja ou em trânsito, diretamente pelo aplicativo.']
  ];
  document.querySelectorAll('[data-feature]').forEach(button => button.addEventListener('click', () => {
    const feature = features[Number(button.dataset.feature)];
    showDialog(feature[0], feature[1]);
  }));
  document.querySelector('[data-video]').addEventListener('click', () => {
    const url = officialUrl('video');
    if (!url) {
      showDialog('Demonstração do StokMobile', 'O vídeo demonstrativo estará disponível em breve. Enquanto isso, conheça as telas do painel, de produtos e do histórico nesta página.');
    } else if (new URL(url).pathname.toLowerCase().endsWith('.mp4')) {
      showDialog('StokMobile em uma operação real', 'Conheça o aplicativo em operação.');
      const video = document.createElement('video');
      video.controls = true;
      video.preload = 'metadata';
      video.src = url;
      content.append(video);
    } else window.location.assign(url);
  });
  document.querySelectorAll('[data-info]').forEach(button => button.addEventListener('click', () => {
    const key = button.dataset.info;
    if (key === 'privacy' || key === 'terms') {
      visitOrExplain(key, key === 'privacy' ? 'Política de privacidade' : 'Termos de uso', 'Este documento estará disponível em breve. Para esclarecimentos, entre em contato pelo e-mail suporte@stokmobile.com.br.');
      return;
    }
    showDialog('Perguntas frequentes', 'Encontre informações sobre o StokMobile.');
    [['Como posso baixar o aplicativo?', 'Use os botões da App Store ou Google Play quando os links oficiais estiverem disponíveis.'], ['Onde encontro os recursos do aplicativo?', 'A seção Recursos apresenta o painel de estoque, as movimentações, o histórico, os alertas e a busca de produtos.'], ['Como falar com a equipe?', 'Envie um e-mail para suporte@stokmobile.com.br.']].forEach(([question, answer]) => {
      const heading = document.createElement('h3');
      heading.textContent = question;
      content.append(heading);
      paragraph(answer);
    });
  }));
})();
