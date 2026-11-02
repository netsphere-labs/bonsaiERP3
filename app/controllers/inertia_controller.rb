# frozen_string_literal: true

class InertiaController < ApplicationController

  # If this option is `true`, you may set `component_path_resolver`
  # default:
  #   render inertia: { user: user}   => renders users/show.jsx
  inertia_config default_render: true

  inertia_share flash: -> { flash.to_hash }

  # Share data with all Inertia responses
  # see https://inertia-rails.dev/guide/shared-data
  inertia_share current_user: -> {
    current_user &.as_json(only: [:id, :first_name, :last_name, :email])
  }


private

  # Inertia's `useForm` hook expects the `errors` object to have values as
  # single strings (e.g., `"This field is required"`).
  # https://inertia-rails.dev/cookbook/handling-validation-error-types
  def inertia_errors(model)
    return {
      errors: model.errors.to_hash(true).transform_values(&:to_sentence)
    }
  end

end
