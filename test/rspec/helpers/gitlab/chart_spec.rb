require_relative '../../../../src/bin/helpers/gitlab/chart.rb'
require 'tmpdir'

describe Gitlab::Chart do
  describe '.load_from_helm_ls' do
    subject { described_class.load_from_helm_ls(data, release_name) }

    let(:release_name) { 'production' }

    let(:data) do
      <<~EOS
        [
          {
            "name": "production",
            "revision": 1,
            "updated":"2020-08-18 11:26:58.055761 -0400 EDT",
            "status": "deployed",
            "chart": "auto-deploy-app-1.2.3",
            "app_version": "",
            "namespace": "new-sentimentality-19561312-production"
          },
          {
            "name": "production-canary",
            "revision": 2,
            "updated":"2020-08-18 11:26:58.055761 -0400 EDT",
            "status": "deployed",
            "chart": "auto-deploy-app-4.5.6",
            "app_version": "",
            "namespace": "new-sentimentality-19561312-production"
          },
          {
            "name": "production-postgresql",
            "revision": 9,
            "updated":"2020-08-18 11:26:58.055761 -0400 EDT",
            "status": "deployed",
            "chart": "postgresql-8.2.1",
            "app_version": "11.6.0",
            "namespace": "new-sentimentality-19561312-production"
          }
        ]
      EOS
    end

    it 'correctly loads the chart' do
      expect(subject.major).to eq(1)
      expect(subject.minor).to eq(2)
      expect(subject.patch).to eq(3)
    end

    context 'when release name is canary' do
      let(:release_name) { 'production-canary' }

      it 'correctly loads the chart' do
        expect(subject.major).to eq(4)
        expect(subject.minor).to eq(5)
        expect(subject.patch).to eq(6)
      end
    end

    context 'when release name does not exist' do
      let(:release_name) { 'production-unknown' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when chart is not gitlab managed chart' do
      let(:release_name) { 'production-postgresql' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when data is empty' do
      let(:data) { '[]' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when data is nil' do
      let(:data) { nil }

      it 'raises an error' do
        expect { subject }.to raise_error(TypeError)
      end
    end

    context 'when data is not formatted in json' do
      let(:data) { 'test' }

      it 'raises an error' do
        expect { subject }.to raise_error(JSON::ParserError)
      end
    end
  end

  describe '.load_from_chart_yml' do
    let(:chart_yaml) do
      <<~EOS
      apiVersion: v1
      description: GitLab's Auto-deploy Helm Chart
      name: auto-deploy-app
      version: 1.0.0-beta.0
      icon: https://gitlab.com/gitlab-com/gitlab-artwork/raw/master/logo/logo-square.png
      EOS
    end

    it 'correctly loads the chart' do
      in_chart_dir do |dir|
        chart = described_class.load_from_chart_yml(dir)

        expect(chart.major).to eq(1)
        expect(chart.minor).to eq(0)
        expect(chart.patch).to eq(0)
      end
    end

    context 'when chart is not gitlab managed chart' do
      let(:chart_yaml) do
        <<~EOS
        apiVersion: v1
        description: GitLab's Auto-deploy Helm Chart
        name: custom-chart
        version: 1.0.0-beta.0
        icon: https://gitlab.com/gitlab-com/gitlab-artwork/raw/master/logo/logo-square.png
        EOS
      end

      it 'returns nil' do
        in_chart_dir do |dir|
          chart = described_class.load_from_chart_yml(dir)

          expect(chart).to be_nil
        end
      end
    end

    context 'when chart yaml is not found' do
      it 'raises an error' do
        expect { described_class.load_from_chart_yml('test') }.to raise_error(Errno::ENOENT)
      end
    end

    def in_chart_dir
      Dir.mktmpdir do |dir|
        File.write("#{dir}/Chart.yaml", chart_yaml)
        yield dir
      end
    end
  end
end
