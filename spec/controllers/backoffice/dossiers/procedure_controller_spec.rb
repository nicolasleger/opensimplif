require 'rails_helper'

describe Backoffice::Dossiers::ProcedureController, type: :controller do
  let(:gestionnaire) { create :gestionnaire }
  let(:procedure) { create :procedure }

  before do
    create :assign_to, gestionnaire: gestionnaire, procedure: procedure
    sign_in gestionnaire
    gestionnaire.build_default_preferences_list_dossier procedure.id
  end

  describe 'GET #index' do
    let(:procedure_id) { procedure.id }

    subject { get :index, params: {id: procedure_id} }

    it { expect(subject.status).to eq 302 }

    context 'when procedure id is not found' do
      let(:procedure_id) { 100_000 }

      before do
        subject
      end

      it { expect(response.status).to eq 302 }
      it { is_expected.to redirect_to simplifications_path }
      it { expect(flash[:alert]).to be_present }
    end
  end

  describe 'GET #filter' do
    subject { get :filter, params: {id: procedure.id, filter_input: {'user.email' => 'plop@plop.com'}} }

    it { is_expected.to redirect_to simplification_path(id: procedure.id) }
  end
end
