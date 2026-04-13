<script lang="ts">
  import { onMount } from 'svelte';
  import { api, type Project } from '../lib/api';
  import ProjectForm from './ProjectForm.svelte';

  let project = $state<Project | null>(null);
  let loading = $state(true);
  let error = $state('');

  onMount(async () => {
    const id = new URLSearchParams(window.location.search).get('id');
    if (!id) {
      error = 'ID do projeto não informado.';
      loading = false;
      return;
    }
    try {
      project = await api.getProject(id);
    } catch {
      error = 'Projeto não encontrado.';
    } finally {
      loading = false;
    }
  });
</script>

{#if loading}
  <div class="max-w-lg space-y-6 animate-pulse">
    {#each Array(4) as _}
      <div>
        <div class="h-4 bg-gray-200 rounded w-1/4 mb-2"></div>
        <div class="h-10 bg-gray-200 rounded-xl"></div>
      </div>
    {/each}
  </div>
{:else if error}
  <div class="text-center py-12">
    <p class="text-red-500 text-sm mb-4">{error}</p>
    <a href="/" class="text-sm text-brand hover:underline">Voltar para a lista</a>
  </div>
{:else if project}
  <ProjectForm {project} />
{/if}
