const BASE_URL = import.meta.env.PUBLIC_API_URL || 'http://localhost:3000';

export interface Project {
  id: string;
  name: string;
  client: string;
  startDate: string;
  endDate: string;
  coverImage: string | null;
  isFavorite: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ProjectPayload {
  name: string;
  client: string;
  startDate: string;
  endDate: string;
  coverImage?: string | null;
  isFavorite?: boolean;
}

export interface ListProjectsParams {
  search?: string;
  favorite?: boolean;
  orderBy?: 'alpha' | 'recent' | 'deadline';
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...init?.headers },
    ...init,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw Object.assign(new Error(`HTTP ${res.status}`), { status: res.status, body });
  }
  if (res.status === 204) return undefined as unknown as T;
  return res.json();
}

export const api = {
  listProjects(params: ListProjectsParams = {}): Promise<Project[]> {
    const qs = new URLSearchParams();
    if (params.search) qs.set('search', params.search);
    if (params.favorite) qs.set('favorite', 'true');
    if (params.orderBy) qs.set('orderBy', params.orderBy);
    const query = qs.toString() ? `?${qs}` : '';
    return request<Project[]>(`/api/projects${query}`);
  },

  getProject(id: string): Promise<Project> {
    return request<Project>(`/api/projects/${id}`);
  },

  createProject(payload: ProjectPayload): Promise<Project> {
    return request<Project>('/api/projects', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  },

  updateProject(id: string, payload: Partial<ProjectPayload>): Promise<Project> {
    return request<Project>(`/api/projects/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    });
  },

  deleteProject(id: string): Promise<void> {
    return request<void>(`/api/projects/${id}`, { method: 'DELETE' });
  },
};
