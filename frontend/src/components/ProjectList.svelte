<script lang="ts">
  import { onMount } from 'svelte';
  import { api, type Project } from '../lib/api';
  import ProjectCard from './ProjectCard.svelte';
  import plusCircleIcon from '../assets/icons/plus-circle.png?url';
  import chavronDownIconRaw from '../assets/icons/chevron-down-light.svg?raw';

  type OrderBy = 'alpha' | 'recent' | 'deadline';

  let projects = $state<Project[]>([]);
  let loading = $state(true);
  let error = $state('');
  let favoriteOnly = $state(false);
  let orderBy = $state<OrderBy>('alpha');
  let searchTerm = $state('');
  let hasAnyProjects = $state(false);

  onMount(() => {
    const params = new URLSearchParams(window.location.search);
    const urlSearch = params.get('search') || '';
    const urlFav = params.get('favorite') === 'true';
    const urlOrder = (params.get('orderBy') as OrderBy) || 'alpha';

    searchTerm = urlSearch;
    favoriteOnly = urlFav;
    orderBy = urlOrder;

    loadProjects();
  });

  async function loadProjects() {
    loading = true;
    error = '';
    try {
      const [filtered, all] = await Promise.all([
        api.listProjects({
          search: searchTerm.length >= 3 ? searchTerm : undefined,
          favorite: favoriteOnly || undefined,
          orderBy,
        }),
        api.listProjects({}),
      ]);
      projects = filtered;
      hasAnyProjects = all.length > 0;
    } catch {
      error = 'Erro ao carregar projetos. Verifique se o servidor está rodando.';
    } finally {
      loading = false;
    }
  }

  function updateURL() {
    const params = new URLSearchParams();
    if (searchTerm.length >= 3) params.set('search', searchTerm);
    if (favoriteOnly) params.set('favorite', 'true');
    if (orderBy !== 'alpha') params.set('orderBy', orderBy);
    const query = params.toString();
    window.history.replaceState({}, '', query ? `/?${query}` : '/');
  }

  async function handleFavoriteChange(e: Event) {
    favoriteOnly = (e.target as HTMLInputElement).checked;
    updateURL();
    await loadProjects();
  }

  const orderOptions: { value: OrderBy; label: string }[] = [
    { value: 'alpha', label: 'Ordem alfabética' },
    { value: 'recent', label: 'Iniciados mais recentes' },
    { value: 'deadline', label: 'Prazo mais próximo' },
  ];

  let orderDropdownOpen = $state(false);

  function getChevronDownIcon(isOpen: boolean): string {
    const colorClass = isOpen ? 'text-brand' : 'text-header-bg';
    return chavronDownIconRaw
      .replace('fill="#717171"', 'fill="currentColor"')
      .replace('<svg ', `<svg class="w-4 h-4 shrink-0 transition-transform ${isOpen ? 'rotate-180' : ''} ${colorClass}" `);
  }

  async function selectOrder(value: OrderBy) {
    orderBy = value;
    orderDropdownOpen = false;
    updateURL();
    await loadProjects();
  }

  function handleDelete(id: string) {
    projects = projects.filter((p) => p.id !== id);
  }

  function handleFavoriteToggle(updated: Project) {
    projects = projects.map((p) => (p.id === updated.id ? updated : p));
    if (favoriteOnly && !updated.isFavorite) {
      projects = projects.filter((p) => p.id !== updated.id);
    }
  }
</script>

<div>
  {#if searchTerm.length >= 3}
    <p class="text-sm text-gray-500 mb-4">
      Mostrando resultados para: <strong>"{searchTerm}"</strong>
    </p>
  {/if}

  {#if loading}
    <div class="grid gap-[32px] grid-cols-1 sm:[grid-template-columns:repeat(auto-fill,346px)]">
      {#each Array(4) as _}
        <div class="bg-white rounded-2xl overflow-hidden shadow-sm border border-gray-100 animate-pulse">
          <div class="h-40 bg-gray-200"></div>
          <div class="p-4 space-y-2">
            <div class="h-4 bg-gray-200 rounded w-3/4"></div>
            <div class="h-3 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
      {/each}
    </div>
  {:else if error}
    <div class="text-center">
      <p class="text-red-500 text-sm">{error}</p>
    </div>
  {:else if !hasAnyProjects}
    <div class="text-center bg-empty-content flex min-h-[calc(100vh-164px)] rounded-sm flex-col items-center justify-center">
      <h2 class="w-full ext-lg font-semibold text-[24px] text-empty-title leading-[100%]">
        {searchTerm.length >= 3 ? 'Nenhum projeto encontrado' : 'Nenhum projeto'}
      </h2>
      <p class="text-base text-empty-text pt-[24px] pb-[32px] font-normal">
        {searchTerm.length >= 3
          ? 'Tente uma busca diferente'
          : 'Clique no botão abaixo para criar o primeiro e gerenciá-lo.'}
      </p>
      {#if searchTerm.length < 3}
        <a
          href="/projects/new"
          class="px-[32px] py-[15px] text-white text-xl font-normal leading-[22px] rounded-full bg-empty-btn-bg transition-colors"
        >
          Novo projeto
        </a>
      {/if}
    </div>
  {:else}
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <h1 class="text-2xl font-bold text-main-title">
        {searchTerm.length >= 3 ? `Resultado da busca` : 'Projetos'}
        {#if !loading}
          <span class="text-main-accent font-normal text-lg">({projects.length})</span>
        {/if}
      </h1>

      <div class="flex flex-col sm:flex-row sm:items-center gap-3 w-full sm:w-auto">
        <label class="flex items-center gap-2 cursor-pointer select-none">
          <input
            type="checkbox"
            checked={favoriteOnly}
            onchange={handleFavoriteChange}
            class="sr-only peer"
          />
          <span class="relative inline-flex w-[48px] h-[24px] rounded-full transition-colors duration-200
            [background-color:var(--color-toggle-off)] peer-checked:[background-color:var(--color-toggle-on)]
            after:content-[''] after:absolute after:top-[6px] after:left-[6px]
            after:w-3 after:h-3 after:rounded-full after:bg-white after:shadow
            after:transition-transform after:duration-200
            peer-checked:after:translate-x-6">
          </span>
          <span class="text-base text-gray-600">Apenas Favoritos</span>
        </label>

        <div class="relative sm:ml-8 w-full sm:w-auto">
          {#if orderDropdownOpen}
            <div class="fixed inset-0 z-10" onclick={() => (orderDropdownOpen = false)} onkeydown={() => {}}></div>
          {/if}
          <button
            type="button"
            onclick={() => (orderDropdownOpen = !orderDropdownOpen)}
            class="h-[40px] w-full sm:w-[296px] flex items-center justify-between pl-4 pr-3 text-base border rounded-lg cursor-pointer bg-white text-header-bg transition-colors
              {orderDropdownOpen ? 'border-brand rounded-t-lg rounded-b-none' : 'border-main-muted'}"
          >
            <span>{orderOptions.find(o => o.value === orderBy)?.label}</span>
            {@html getChevronDownIcon(orderDropdownOpen)}
          </button>

          {#if orderDropdownOpen}
            <div class="absolute left-0 top-[39px] w-full sm:w-[296px] bg-white border border-brand rounded-b-2xl z-20 overflow-hidden shadow-sm">
              {#each orderOptions as option}
                <button
                  type="button"
                  onclick={() => selectOrder(option.value)}
                  class="w-full text-left px-4 py-3 text-base text-header-bg hover:bg-brand/5 transition-colors cursor-pointer"
                >
                  {option.label}
                </button>
              {/each}
            </div>
          {/if}
        </div>

        <a
          href="/projects/new"
          class="h-[40px] w-full sm:w-[184px] flex items-center justify-center gap-2 px-5 bg-brand text-white text-base font-normal rounded-full hover:bg-brand-dark transition-colors sm:ml-8"
        >
          <img src={plusCircleIcon} alt="Novo projeto" class="w-6 h-6 shrink-0" />
          Novo projeto
        </a>
      </div>
    </div>

    {#if projects.length === 0}
      <p class="text-center text-gray-500 mt-16">Nenhum projeto corresponde aos filtros aplicados.</p>
    {:else}
      <div class="grid gap-[32px] grid-cols-1 sm:[grid-template-columns:repeat(auto-fill,346px)]">
        {#each projects as project (project.id)}
          <ProjectCard
            {project}
            highlight={searchTerm}
            onDelete={handleDelete}
            onFavoriteToggle={handleFavoriteToggle}
          />
        {/each}
      </div>
    {/if}
  {/if}
</div>
