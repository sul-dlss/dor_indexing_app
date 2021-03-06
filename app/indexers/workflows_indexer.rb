# frozen_string_literal: true

# Indexes the objects position in workflows
class WorkflowsIndexer
  attr_reader :id

  def initialize(id:, **)
    @id = id
  end

  # @return [Hash] the partial solr document for workflow concerns
  def to_solr
    Rails.logger.debug "In #{self.class}"

    WorkflowSolrDocument.new do |combined_doc|
      workflows.each do |wf|
        doc = WorkflowIndexer.new(workflow: wf).to_solr
        combined_doc.merge!(doc)
      end
    end.to_h
  end

  private

  # @return [Array<Workflow::Response::Workflow>]
  def workflows
    all_workflows.workflows
  end

  # TODO: remove Dor::Workflow::Document
  # @return [Workflow::Response::Workflows]
  def all_workflows
    @all_workflows ||= WorkflowClientFactory.build.workflow_routes.all_workflows pid: id
  end
end
