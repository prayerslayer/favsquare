require 'queue_classic'

Sequel.migration do
  up {QC::Setup.create}
  down {QC::Setup.drop}
end