class SampleMail < MailForm::Base
  attributes :name, :email, :nickname

  validates :nickname, absence: true

  before_deliver do
    evaluated_callbacks << :before
  end

  after_deliver do
    evaluated_callbacks << :after
  end

  def initialize(attributes={})
    attributes.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if attributes
  end

  def evaluated_callbacks
    @evaluated_callbacks ||= []
  end

  def headers
    { to: "reciepient@example.com", from: self.email }
  end
end