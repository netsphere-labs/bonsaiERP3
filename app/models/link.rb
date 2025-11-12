
# author: Boris Barroso
# email: boriscyber@gmail.com


class Link < ApplicationRecord
  self.table_name = "public.links"

  belongs_to :organisation, inverse_of: :links
  belongs_to :user, inverse_of: :active_links

  validates_presence_of :role, :organisation_id
  validates_inclusion_of :role, in: User::ROLES

  scope :org_links, -> (org_id) { where(organisation_id: org_id) }
  scope :active, -> { where(active: true).where.not(api_token: nil) }

  #scope :auth, -> (token) {  }

  def self.auth(token, tenant)
    active.eager_load(:user).where(active: true, api_token: token, tenant: tenant).first
  end
end
