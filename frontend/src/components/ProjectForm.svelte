<script lang="ts">
  import { api, type Project, type ProjectPayload } from '../lib/api';
  import uploadIcon from '../assets/icons/upload-light.svg?url';
  import trashIcon from '../assets/icons/trash.svg?url';
  import calendarDayIcon from '../assets/icons/calendar-day-light.svg?url';
  import calendarCheckIcon from '../assets/icons/calendar-check-light.svg?url';

  interface Props {
    project?: Project | null;
  }

  let { project = null }: Props = $props();

  let name = $state(project?.name ?? '');
  let client = $state(project?.client ?? '');
  let startDate = $state(project?.startDate ?? '');
  let endDate = $state(project?.endDate ?? '');
  let coverImage = $state<string | null>(project?.coverImage ?? null);
  let fileInput = $state<HTMLInputElement | null>(null);
  let saving = $state(false);
  let errors = $state<Record<string, string>>({});
  let startDateType = $state(project?.startDate ? 'date' : 'text');
  let endDateType = $state(project?.endDate ? 'date' : 'text');

  const hasTwoWords = (v: string) => v.trim().split(/\s+/).filter(Boolean).length >= 2;
  const isValidDate = (v: string) => /^\d{4}-\d{2}-\d{2}$/.test(v);

  function limitYear(e: Event) {
    const input = e.target as HTMLInputElement;
    if (!input.value) return;
    const [y, m, d] = input.value.split('-');
    if (y && y.length > 4) {
      input.value = [y.slice(0, 4), m, d].filter(Boolean).join('-');
    }
  }

  function clearError(...fields: string[]) {
    const e = { ...errors };
    fields.forEach((f) => delete e[f]);
    errors = e;
  }

  function validateNameField() {
    const e = { ...errors };
    if (!name.trim()) e.name = 'Nome é obrigatório';
    else if (!hasTwoWords(name)) e.name = 'Por favor, digite ao menos duas palavras';
    else delete e.name;
    errors = e;
  }

  function validateClientField() {
    const e = { ...errors };
    if (!client.trim()) e.client = 'Por favor, digite ao menos uma palavra';
    else delete e.client;
    errors = e;
  }

  function validateStartDate() {
    const e = { ...errors };
    if (!startDate || !isValidDate(startDate)) e.startDate = 'Selecione uma data válida';
    else delete e.startDate;
    if (isValidDate(startDate) && isValidDate(endDate) && endDate <= startDate) {
      e.endDate = 'A data final deve ser maior que a data inicial';
    } else if (isValidDate(endDate)) {
      delete e.endDate;
    }
    errors = e;
  }

  function validateEndDate() {
    const e = { ...errors };
    if (!endDate || !isValidDate(endDate)) e.endDate = 'Selecione uma data válida';
    else delete e.endDate;
    if (isValidDate(startDate) && isValidDate(endDate) && endDate <= startDate) {
      e.endDate = 'A data final deve ser maior que a data inicial';
    }
    errors = e;
  }

  function validate(): boolean {
    const e: Record<string, string> = {};
    if (!name.trim()) e.name = 'Nome é obrigatório';
    else if (!hasTwoWords(name)) e.name = 'Por favor, digite ao menos duas palavras';
    if (!client.trim()) e.client = 'Por favor, digite ao menos uma palavra';
    if (!startDate || !isValidDate(startDate)) e.startDate = 'Selecione uma data válida';
    if (!endDate || !isValidDate(endDate)) e.endDate = 'Selecione uma data válida';
    else if (isValidDate(startDate) && endDate <= startDate) e.endDate = 'A data final deve ser maior que a data inicial';
    errors = e;
    return Object.keys(e).length === 0;
  }

  const isValid = $derived(
    name.trim() !== '' &&
    hasTwoWords(name) &&
    client.trim() !== '' &&
    isValidDate(startDate) &&
    isValidDate(endDate) &&
    endDate > startDate
  );

  async function handleSubmit(e: Event) {
    e.preventDefault();
    if (!validate()) return;

    saving = true;
    try {
      const payload: ProjectPayload = { name, client, startDate, endDate, coverImage };
      if (project) {
        await api.updateProject(project.id, payload);
      } else {
        await api.createProject(payload);
      }
      window.location.href = '/';
    } catch (err: unknown) {
      const apiErr = err as { body?: { errors?: { field: string; message: string }[] } };
      if (apiErr?.body?.errors) {
        const e: Record<string, string> = {};
        for (const { field, message } of apiErr.body.errors) e[field] = message;
        errors = e;
      }
    } finally {
      saving = false;
    }
  }

  function handleImageUpload(e: Event) {
    const file = (e.target as HTMLInputElement).files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => { coverImage = reader.result as string; };
    reader.readAsDataURL(file);
  }

  function removeCover() { coverImage = null; }
</script>

<section class="w-full flex justify-center border border-[color:var(--color-border)] rounded-lg py-[52px]">
  <form onsubmit={handleSubmit} class="space-y-6 max-w-[702px] w-full">
    <div>
      <label class="block text-sm font-medium mb-1 {errors.name ? 'text-form-error-bold' : 'text-brand'}" for="name">
        Nome do projeto <span class="text-sm font-normal {errors.name ? 'text-form-error' : 'text-empty-text'}">(Obrigatório)</span>
      </label>
      <input
        id="name"
        type="text"
        bind:value={name}
        oninput={() => errors.name && clearError('name')}
        onblur={validateNameField}
        class="w-full px-4 h-[40px] py-0 rounded-lg border {errors.name ? 'border-form-error text-form-error' : 'border-main-muted'} text-sm outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
      />
      {#if errors.name}<p class="mt-1 text-sm text-form-error">{errors.name}</p>{/if}
    </div>

    <div>
      <label class="block text-sm font-medium mb-1 {errors.client ? 'text-form-error-bold' : 'text-brand'}" for="client">
        Cliente <span class="text-sm font-normal {errors.client ? 'text-form-error' : 'text-empty-text'}">(Obrigatório)</span>
      </label>
      <input
        id="client"
        type="text"
        bind:value={client}
        oninput={() => errors.client && clearError('client')}
        onblur={validateClientField}
        class="w-full px-4 h-[40px] py-0 rounded-lg border {errors.client ? 'border-form-error text-form-error' : 'border-main-muted'} text-sm outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand"
      />
      {#if errors.client}<p class="mt-1 text-sm text-form-error">{errors.client}</p>{/if}
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div>
        <label class="block text-sm font-medium mb-1 {errors.startDate ? 'text-form-error-bold' : 'text-brand'}" for="startDate">
          Data de Início <span class="text-sm font-normal {errors.startDate ? 'text-form-error' : 'text-empty-text'}">(Obrigatório)</span>
        </label>
        <div class="relative">
          <input
            id="startDate"
            type={startDateType}
            bind:value={startDate}
            onfocus={() => { startDateType = 'date'; }}
            oninput={(e) => { limitYear(e); (errors.startDate || errors.endDate) && clearError('startDate', 'endDate'); }}
            onblur={() => { if (!startDate) startDateType = 'text'; validateStartDate(); }}
            class="w-full px-4 h-[40px] py-0 pr-10 rounded-sm border {errors.startDate ? 'border-form-error text-form-error' : 'border-main-muted'} text-sm outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand [&::-webkit-calendar-picker-indicator]:opacity-0 [&::-webkit-calendar-picker-indicator]:absolute [&::-webkit-calendar-picker-indicator]:right-0 [&::-webkit-calendar-picker-indicator]:w-10 [&::-webkit-calendar-picker-indicator]:h-full [&::-webkit-calendar-picker-indicator]:cursor-pointer"
          />
          <img src={calendarDayIcon} alt="" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-6 h-6 {errors.startDate ? 'brightness-0 saturate-100 [filter:invert(20%)_sepia(90%)_saturate(700%)_hue-rotate(340deg)]' : ''}" />
        </div>
        {#if errors.startDate}<p class="mt-1 text-sm text-form-error">{errors.startDate}</p>{/if}
      </div>
      <div>
        <label class="block text-sm font-medium mb-1 {errors.endDate ? 'text-form-error-bold' : 'text-brand'}" for="endDate">
          Data Final <span class="text-sm font-normal {errors.endDate ? 'text-form-error' : 'text-empty-text'}">(Obrigatório)</span>
        </label>
        <div class="relative">
          <input
            id="endDate"
            type={endDateType}
            bind:value={endDate}
            onfocus={() => { endDateType = 'date'; }}
            oninput={(e) => { limitYear(e); (errors.startDate || errors.endDate) && clearError('startDate', 'endDate'); }}
            onblur={() => { if (!endDate) endDateType = 'text'; validateEndDate(); }}
            class="w-full px-4 h-[40px] py-0 pr-10 rounded-sm border {errors.endDate ? 'border-form-error text-form-error' : 'border-main-muted'} text-sm outline-none focus:ring-2 focus:ring-brand/30 focus:border-brand [&::-webkit-calendar-picker-indicator]:opacity-0 [&::-webkit-calendar-picker-indicator]:absolute [&::-webkit-calendar-picker-indicator]:right-0 [&::-webkit-calendar-picker-indicator]:w-10 [&::-webkit-calendar-picker-indicator]:h-full [&::-webkit-calendar-picker-indicator]:cursor-pointer"
          />
          <img src={calendarCheckIcon} alt="" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-6 h-6 {errors.endDate ? 'brightness-0 saturate-100 [filter:invert(20%)_sepia(90%)_saturate(700%)_hue-rotate(340deg)]' : ''}" />
        </div>
        {#if errors.endDate}<p class="mt-1 text-sm text-form-error">{errors.endDate}</p>{/if}
      </div>
    </div>
  
    <div>
      <label class="block text-sm font-medium text-brand mb-1">Capa do projeto</label>
      {#if coverImage}
        <div class="relative w-full h-40 rounded-xl overflow-hidden border border-gray-200">
          <img src={coverImage} alt="Capa" class="w-full h-full object-cover" />
          <button
            type="button"
            onclick={removeCover}
            class="absolute top-2 right-2 w-8 h-8 rounded-full bg-white text-white flex items-center justify-center hover:bg-main-muted cursor-pointer"
            aria-label="Remover capa"
          >
            <img src={trashIcon} alt="Capa" class="w-3 h-4 object-cover" />
          </button>
        </div>
      {:else}
        <label
          class="flex flex-col items-center justify-center w-full h-[174px] border-1 border-dashed border-main-muted rounded-lg cursor-pointer hover:border-brand hover:bg-brand/5 transition-colors"
        >
          <img src={uploadIcon} alt="Upload" class="w-6 h6 text-gray-400 mb-4" />
          <span class="text-base text-empty-text pb-6">Escolha uma imagem .jpg ou .png no seu dispositivo</span>
          <input bind:this={fileInput} type="file" accept="image/jpeg,image/png" class="hidden" onchange={handleImageUpload} />
          <div class="flex gap-3">
            <button
              type="button"
              onclick={() => fileInput?.click()}
              class="h-[40px] w-[144px] flex-1 px-8 rounded-full bg-empty-btn-text text-main-accent text-base hover:bg-brand-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed border border-[color:var(--empty-btn-text)]"
            >
              Selecionar
            </button>
          </div>
        </label>
      {/if}
    </div>
  
    <div class="flex gap-3 pt-2">
      <button
        type="submit"
        disabled={!isValid || saving}
        class="h-[52px] flex-1 px-6 rounded-full bg-brand text-white text-xl hover:bg-brand-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
      >
        {saving ? 'Salvando...' : 'Salvar projeto'}
      </button>
    </div>
  </form>
</section>
