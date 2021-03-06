require 'rails_helper'

describe Users::RegistrationsController, type: :controller do
  let(:email) { 'test@octo.com' }
  let(:password) { 'password' }

  let(:user) { {email: email, password: password, password_confirmation: password} }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '.create' do
    subject { post :create, params: {user: user} }

    context 'when user is correct' do
      it { expect(described_class).to be < Devise::RegistrationsController }

      describe '#check_invite!' do
        let!(:invite) { create :invite, email: email }
        let!(:invite2) { create :invite, email: email }

        before do
          subject
        end

        it 'the new user is connect at his two invite' do
          expect(User.last.invites.size).to eq 2
        end
      end
    end

    context 'when user is not correct' do
      let(:user) { {email: '', password: password, password_confirmation: password} }

      it 'not sends welcome email' do
        expect(WelcomeMailer).not_to receive(:welcome_email)

        subject
      end
    end
  end
end
