describe Idcf::Dns::ClientExtensions::Record do
  include_context "resources"
  before { ZONES << client.create_zone(zone_attributes).uuid }
  let(:zone_uuid) { ZONES.last }
  let(:zone) { client.get_zone(zone_uuid) }
  let(:attributes) { record_attributes(name: "#{rand(16**8).to_s(16)}.#{zone['name']}") }

  describe "#create_record" do
    let(:response) { client.create_record(zone_uuid, attributes) }

    context "when valid request" do
      it do
        expect(response.status).to eq 201
        expect(response.success?).to be_truthy
        expect(response.uuid).not_to be nil
      end
    end

    context "when invalid request with unnecessary attributes" do
      let(:invalid_attributes) { attributes.merge(unnecessary: "") }
      let(:response) { client.create_record(zone_uuid, invalid_attributes) }

      it do
        expect { response }.to raise_error(Idcf::Dns::UnnecessaryAttribute)
      end
    end

    context "when invalid request with missing required attribute" do
      let(:attributes) { record_attributes }

      it do
        expect { response }.to raise_error(Idcf::Dns::MissingAttribute)
      end
    end
  end

  describe "#delete_record" do
    let(:response) { client.delete_record(zone_uuid, uuid) }
    let(:uuid) { client.create_record(zone_uuid, attributes).uuid }

    context "when valid request" do
      it do
        expect(response.status).to eq 200
        expect(response.success?).to be_truthy
      end
    end

    context "when deleting a non-existing record" do
      let(:uuid) { random_uuid }

      it do
        expect { client.delete_record(zone_uuid, uuid) }.to raise_error(Idcf::Dns::ApiError)
      end
    end
  end

  describe "#get_record" do
    let(:response) { client.get_record(zone_uuid, uuid) }

    context "when valid request" do
      let(:uuid) { client.create_record(zone_uuid, attributes).uuid }

      it do
        expect(response.status).to eq 200
        expect(response.success?).to be_truthy
        expect(response.body).to be_an_instance_of(Hash)
      end
    end
  end

  describe "#list_records" do
    let(:response) { client.list_records(zone_uuid) }

    context "when valid request" do
      let(:zone_uuid) { ZONES.last }

      it do
        expect(response.status).to eq 200
        expect(response.success?).to be_truthy
        expect(response.body).to be_an_instance_of(Array)
      end
    end
  end

  describe "#update_record" do
    let(:response) { client.update_record(zone_uuid, uuid, update_attributes) }

    context "when valid request" do
      let(:uuid) { client.create_record(zone_uuid, attributes).uuid }
      let(:update_attributes) { { content: "1.1.1.1" } }

      it do
        expect(response.status).to eq 200
        expect(response.success?).to be_truthy
      end
    end
  end
end
