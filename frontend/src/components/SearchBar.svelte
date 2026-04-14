<script lang="ts">
  import { onMount } from 'svelte';
  import searchIcon from '../assets/icons/search.svg?url';
  import searchInnerIcon from '../assets/icons/search-inner.svg?url';
  import clockIcon from '../assets/icons/history.svg?url';
  import removeIcon from '../assets/icons/remove.svg?url';

  const HISTORY_KEY = 'search-history';
  const MAX_HISTORY = 5;
  const MIN_CHARS = 3;
  const DEBOUNCE_MS = 600;

  let query = $state('');
  let open = $state(false);
  let searchActive = $state(false);
  let history = $state<string[]>([]);
  let timer: ReturnType<typeof setTimeout>;
  let inputRef: HTMLInputElement;

  onMount(() => {
    const stored = localStorage.getItem(HISTORY_KEY);
    if (stored) history = JSON.parse(stored);

    const params = new URLSearchParams(window.location.search);
    const urlSearch = params.get('search') || '';
    query = urlSearch;
    searchActive = urlSearch.length >= MIN_CHARS;
  });

  function saveHistory(term: string) {
    const filtered = history.filter((h) => h !== term);
    history = [term, ...filtered].slice(0, MAX_HISTORY);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
  }

  function removeHistory(term: string, e: Event) {
    e.stopPropagation();
    history = history.filter((h) => h !== term);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
  }

  function navigate(term: string) {
    if (!term || term.length < MIN_CHARS) return;
    saveHistory(term);
    open = false;
    const url = new URL(window.location.href);
    url.pathname = '/';
    url.searchParams.set('search', term);
    window.location.href = url.toString();
  }

  function clearSearch() {
    clearTimeout(timer);
    query = '';
    searchActive = false;
    const url = new URL(window.location.href);
    url.pathname = '/';
    url.searchParams.delete('search');
    window.location.href = url.toString();
  }

  function onInput() {
    clearTimeout(timer);
    if (query.length === 0) {
      timer = setTimeout(() => {
        searchActive = false;
        const url = new URL(window.location.href);
        url.pathname = '/';
        url.searchParams.delete('search');
        window.location.href = url.toString();
      }, DEBOUNCE_MS);
      return;
    }
    if (query.length < MIN_CHARS) return;
    timer = setTimeout(() => navigate(query), DEBOUNCE_MS);
  }

  function onKeydown(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      clearTimeout(timer);
      navigate(query);
    }
    if (e.key === 'Escape') {
      if (searchActive) {
        clearSearch();
      } else {
        open = false;
      }
    }
  }

  function openSearch() {
    open = true;
    setTimeout(() => inputRef?.focus(), 50);
  }
</script>

<svelte:window onkeydown={(e) => {
  if (e.key === 'Escape') {
    if (searchActive) clearSearch();
    else if (open) open = false;
  }
}} />

{#if !searchActive && !open}
  <button
    onclick={openSearch}
    class="w-8 h-8 flex items-center justify-center cursor-pointer"
    aria-label="Abrir busca"
  >
    <img src={searchIcon} alt="Buscar" class="w-5 h-5" />
  </button>
{/if}

{#if searchActive}
  <div class="fixed left-0 right-0 top-0 z-50 bg-white border-b border-[color:var(--color-border)]" style="box-shadow: 0px 4px 4px 0px #00000040;">
    <div class="flex items-center gap-4 px-6 h-[80px]">
      <img src={searchInnerIcon} alt="Buscar" class="w-5 h-5 shrink-0" />
      <input
        bind:this={inputRef}
        bind:value={query}
        type="search"
        placeholder="Digite o nome do projeto..."
        class="flex-1 text-lg outline-none text-header-bg [&::-webkit-search-cancel-button]:hidden"
        oninput={onInput}
        onkeydown={onKeydown}
      />
    </div>
  </div>
{/if}

{#if open && !searchActive}
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    class="fixed inset-0 z-40"
    onclick={() => (open = false)}
    onkeydown={() => {}}
  ></div>

  <div class="fixed left-0 right-0 top-0 z-50 bg-white {history.length > 0 ? 'border-2 border-brand rounded-[16px]' : 'border-b border-[color:var(--color-border)]'}" style="box-shadow: 0px 4px 4px 0px #00000040;">
    <div class="flex items-center gap-4 px-6 h-[80px]">
      <img src={searchInnerIcon} alt="Buscar" class="w-5 h-5 shrink-0" />
      <input
        bind:this={inputRef}
        bind:value={query}
        type="search"
        placeholder="Digite o nome do projeto..."
        class="flex-1 text-lg outline-none placeholder:text-[color:var(--color-main-muted)] text-[color:var(--color-main-body)]"
        oninput={onInput}
        onkeydown={onKeydown}
      />
    </div>

    {#if history.length > 0}
      {#each history as term}
        <button
          class="flex items-center justify-between w-full px-6 py-4 text-base text-empty-text hover:bg-brand/5 transition-colors last:border-b-0"
          onmousedown={() => { query = term; navigate(term); }}
        >
          <div class="flex items-center gap-4">
            <img src={clockIcon} alt="Histórico" class="w-4 h-4 shrink-0" />
            <span>{term}</span>
          </div>
          <div
            role="button"
            tabindex="0"
            aria-label="Remover histórico"
            class="w-4 h-4 cursor-pointer flex items-center justify-center"
            onmousedown={(e) => removeHistory(term, e)}
            onkeydown={(e) => e.key === 'Enter' && removeHistory(term, e)}
          >
            <img src={removeIcon} alt="" class="w-5 h-5" />
          </div>
        </button>
      {/each}
    {/if}
  </div>
{/if}
