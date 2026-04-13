module Api
  class ProjectsController < ApplicationController
    before_action :set_project, only: [:show, :update, :destroy]

    def index
      projects = Project.all

      if params[:search].present?
        projects = projects.where("name ILIKE ?", "%#{params[:search]}%")
      end

      if params[:favorite] == "true"
        projects = projects.where(is_favorite: true)
      end

      projects = case params[:orderBy]
                 when "recent"   then projects.order(start_date: :desc)
                 when "deadline" then projects.order(end_date: :asc)
                 else                 projects.order(name: :asc)
                 end

      render json: projects
    end

    def show
      render json: @project
    end

    def create
      project = Project.new(project_params)
      if project.save
        render json: project, status: :created
      else
        render json: { errors: format_errors(project) }, status: :unprocessable_entity
      end
    end

    def update
      if @project.update(project_params)
        render json: @project
      else
        render json: { errors: format_errors(@project) }, status: :unprocessable_entity
      end
    end

    def destroy
      @project.destroy
      head :no_content
    end

    private

    def set_project
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Projeto não encontrado" }, status: :not_found
    end

    def project_params
      params.require(:project).permit(:name, :client, :start_date, :end_date, :cover_image, :is_favorite)
    end

    def format_errors(record)
      record.errors.map { |e| { field: e.attribute.to_s.camelize(:lower), message: e.message } }
    end
  end
end
