require 'rails_helper'

describe Users::Dossiers::CommentairesController, type: :controller do
  let(:dossier) { create(:dossier) }
  let(:texte_commentaire) { 'Commentaire de test' }

  describe '#POST create' do
    subject do
      post :create, params: {dossier_id: dossier.id, texte_commentaire: texte_commentaire}
      dossier.reload
    end

    context 'when invite is connected' do
      let!(:invite) { create(:invite, :with_user, dossier: dossier) }

      before do
        sign_in invite.user
        dossier.replied!
      end

      it do
        subject
        is_expected.to redirect_to users_dossiers_invite_path(invite.id)
        expect(dossier.state).to eq 'replied'
      end
    end

    context 'when user is connected' do
      before do
        sign_in dossier.user
      end

      it 'do not send a mail to notify user' do
        expect(NotificationMailer).not_to receive(:new_answer)
        subject
      end
    end
  end
end
