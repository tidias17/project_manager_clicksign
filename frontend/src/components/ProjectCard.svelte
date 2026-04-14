<script lang="ts">
  import type { Project } from '../lib/api';
  import { api } from '../lib/api';
  import calendarDayIcon from '../assets/icons/calendar-day-light.svg?url';
  import calendarCheckIcon from '../assets/icons/calendar-check-light.svg?url';
  import trashIcon from '../assets/icons/trash.svg?url';
  import editIcon from '../assets/icons/edit.svg?url';
  import dotsIcon from '../assets/icons/dots.svg?url';
  import defaultProjectImage from '../assets/default-project-image.png?url';
  import starIcon from '../assets/icons/star.svg?url';
  import starYellowIcon from '../assets/icons/star-yellow.svg?url';

  interface Props {
    project: Project;
    highlight?: string;
    onDelete?: (id: string) => void;
    onFavoriteToggle?: (project: Project) => void;
  }

  let { project = $bindable(), highlight = '', onDelete, onFavoriteToggle }: Props = $props();

  let menuOpen = $state(false);
  let confirmDelete = $state(false);

  function getHighlighted(text: string, term: string): string {
    if (!term || term.length < 3) return text;
    const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return text.replace(new RegExp(`(${escaped})`, 'gi'), '<mark class="bg-yellow-200 rounded px-0.5">$1</mark>');
  }

  async function toggleFavorite(e: Event) {
    e.stopPropagation();
    const updated = await api.updateProject(project.id, { isFavorite: !project.isFavorite });
    onFavoriteToggle?.(updated);
  }

  function formatDate(dateStr: string): string {
    const [y, m, d] = dateStr.split('-');
    const months = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
    return `${parseInt(d)} de ${months[parseInt(m) - 1]} de ${y}`;
  }
</script>

<svelte:window onkeydown={(e) => e.key === 'Escape' && confirmDelete && (confirmDelete = false)} />

{#if confirmDelete}
  <div
    class="fixed inset-0 bg-black/70 backdrop-blur-[10px] z-50 flex items-center justify-center"
    role="presentation"
    onclick={() => (confirmDelete = false)}
    onkeydown={(e) => e.key === 'Escape' && (confirmDelete = false)}
  >
    <div
      class="relative bg-white rounded-lg pt-12 pb-8 px-6 sm:px-8 w-[calc(100%-32px)] sm:w-[582px] shadow-xl text-center"
      role="dialog"
      aria-modal="true"
      aria-labelledby="delete-dialog-title"
      tabindex="-1"
      onclick={(e) => e.stopPropagation()}
    >
      <div class="absolute -top-6 left-1/2 -translate-x-1/2 w-12 h-12 rounded-full bg-brand flex items-center justify-center shadow-md">
        <img src={trashIcon} alt="" class="w-5 h-5 brightness-0 invert" />
      </div>
      <h2 id="delete-dialog-title" class="text-2xl font-semibold text-main-title mb-3">Remover projeto</h2>
      <hr class="border-[color:var(--color-divider)] mt-6 mb-8" />
      <p class="text-base text-[color:var(--color-main-muted)] mb-3">Essa ação removerá definitivamente o projeto:</p>
      <p class="text-xl sm:text-2xl font-medium text-[color:var(--color-header-bg)] mb-8 truncate">{project.name}</p>
      <div class="flex gap-3 sm:gap-4">
        <button
          class="h-[40px] sm:h-[52px] flex-1 sm:flex-none sm:w-[226px] rounded-full border border-brand text-base sm:text-xl text-brand hover:bg-gray-50 transition-colors"
          onclick={() => (confirmDelete = false)}
        >
          Cancelar
        </button>
        <button
          class="h-[40px] sm:h-[52px] flex-1 sm:flex-none sm:w-[260px] rounded-full bg-brand text-white text-base sm:text-xl hover:bg-brand-dark transition-colors"
          onclick={async () => {
            await api.deleteProject(project.id);
            confirmDelete = false;
            onDelete?.(project.id);
          }}
        >
          Confirmar
        </button>
      </div>
    </div>
  </div>
{/if}

<div class="bg-white rounded-2xl overflow-hidden shadow-sm border border-gray-100 hover:shadow-md transition-shadow w-full sm:w-[346px] h-[430px] flex flex-col">
  <div class="relative h-[232px] shrink-0">
    <img src={project.coverImage ?? defaultProjectImage} alt={project.name} class="w-full h-full object-cover" />

    <div class="absolute bottom-4.5 right-4 flex items-center gap-5">
      <button
        class="w-8 h-8 flex items-center justify-center rounded-full transition-colors"
        onclick={toggleFavorite}
        aria-label={project.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'}
      >
        <img src={project.isFavorite ? starYellowIcon : starIcon} alt="" class="w-7 h-7 block mt-2" />
      </button>

      <div class="relative">
        <button
          class="w-8 h-8 flex items-center justify-center rounded-full text-main-accent bg-white/90 hover:bg-white transition-colors shadow-sm"
          onclick={(e) => { e.stopPropagation(); menuOpen = !menuOpen; }}
          aria-label="Opções do projeto"
        >
          <img src={dotsIcon} alt="" class="w-4 h-4 object-contain" />
        </button>

        {#if menuOpen}
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div
            class="fixed inset-0 z-30"
            onclick={(e) => { e.stopPropagation(); menuOpen = false; }}
            onkeydown={() => {}}
          ></div>
          <div class="absolute right-0 top-11 w-[240px] bg-white rounded-2xl z-40 overflow-visible [box-shadow:0px_4px_4px_0px_#00000040]">
            <div class="absolute -top-[10px] right-3 w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-b-[10px] border-b-white"></div>
            <div class="relative overflow-hidden rounded-2xl">
              <a
                href="/projects/edit?id={project.id}"
                class="flex items-center gap-3 px-5 py-4 text-base text-brand hover:bg-brand/5 transition-colors"
                onclick={(e) => e.stopPropagation()}
              >
                <img src={editIcon} alt="" class="w-6 h-6 shrink-0" />
                Editar
              </a>
              <div class="border-t border-[color:var(--color-empty-bg)] mx-4"></div>
              <button
                class="flex w-full items-center gap-3 px-5 py-4 text-base text-brand hover:bg-brand/5 transition-colors cursor-pointer"
                onclick={(e) => { e.stopPropagation(); menuOpen = false; confirmDelete = true; }}
              >
                <img src={trashIcon} alt="" class="w-6 h-6 shrink-0" />
                Remover
              </button>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>

  <div class="p-6 h-[198px] flex flex-col">
    <h3 class="font-bold text-main-title truncate text-xl">{@html getHighlighted(project.name, highlight)}</h3>
    <p class="text-base text-main-muted truncate mt-1.5">
      <span class="font-bold">Cliente:</span>  {project.client}
    </p>
    <hr class="border-[color:var(--color-divider-card)] my-4" />
    <div class="gap-4 flex flex-col mt-auto">
      <div class="flex items-center gap-4 text-base text-main-muted">
        <img src={calendarDayIcon} alt="" class="w-6 h-6 shrink-0" />
        <span>{formatDate(project.startDate)}</span>
      </div>
      <div class="flex items-center gap-4 text-base text-main-muted">
        <img src={calendarCheckIcon} alt="" class="w-6 h-6 shrink-0" />
        <span>{formatDate(project.endDate)}</span>
      </div>
    </div>
  </div>
</div>
