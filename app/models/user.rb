class User < ActiveRecord::Base
  enum loged_in_with_france_connect: {particulier: 'particulier',
                                      entreprise: 'entreprise'}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :dossiers, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :piece_justificative, dependent: :destroy
  has_many :cerfa, dependent: :destroy
  has_one :france_connect_information, dependent: :destroy

  delegate :given_name, :family_name, :email_france_connect, :gender, :birthdate, :birthplace, :france_connect_particulier_id, to: :france_connect_information
  accepts_nested_attributes_for :france_connect_information

  include CredentialsSyncableConcern

  after_save :create_and_affect_gestionnaire_account

  def self.find_for_france_connect(email, siret)
    user = User.find_by_email(email)
    if user.nil?
      return User.create(email: email, password: Devise.friendly_token[0, 20], siret: siret)
    else
      user.update_attributes(siret: siret)
      user
    end
  end

  def loged_in_with_france_connect?
    !loged_in_with_france_connect.nil?
  end

  def invite?(dossier_id)
    invites.pluck(:dossier_id).include?(dossier_id.to_i)
  end

  def create_and_affect_gestionnaire_account
    gest = Gestionnaire.create email: email, password: encrypted_password

    Procedure.all.each do |procedure|
      AssignTo.create gestionnaire: gest, procedure: procedure
      gest.build_default_preferences_list_dossier procedure.id
    end
  end
end
