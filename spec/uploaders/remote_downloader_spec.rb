require 'rails_helper'

describe RemoteDownloader do
  let(:filename) { 'file_name.pdf' }

  subject { described_class.new filename }

  describe '#url' do
    it { expect(subject.url).to eq 'https://storage.apientreprise.fr/tps_dev/file_name.pdf' }
  end
end
