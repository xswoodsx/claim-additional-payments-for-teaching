require "delegate"
require "csv"

class TslrClaimCsvRow < SimpleDelegator
  def to_s
    CSV.generate_line(data)
  end

  private

  DANGEROUS_STRINGS = [
    "-",
    "+",
    "=",
    "@",
  ].freeze

  def data
    TslrClaimsCsv::FIELDS.map do |f|
      field = send(f)
      sanitize_field(field)
    end
  end

  def employment_status
    model.employment_status.humanize
  end

  def date_of_birth
    model.date_of_birth.strftime("%d/%m/%Y")
  end

  def mostly_teaching_eligible_subjects
    model.mostly_teaching_eligible_subjects? ? "Yes" : "No"
  end

  def student_loan_repayment_amount
    "£#{model.student_loan_repayment_amount}"
  end

  def student_loan_repayment_plan
    model.student_loan_plan&.humanize
  end

  def submitted_at
    model.submitted_at.strftime("%d/%m/%Y %H:%M")
  end

  def sanitize_field(field)
    return field if field.blank?

    field = "=\"#{field}\"" if DANGEROUS_STRINGS.any? { |string| field.include?(string) }
    field
  end

  def model
    __getobj__
  end
end
