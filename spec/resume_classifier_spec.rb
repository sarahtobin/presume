require "spec_helper"
require "benchmark"

describe ResumeClassifier do
  let(:doc) { Docx::Document.open('sample_resume.docx').text }
  let(:resume_classifier){ResumeClassifier.new(doc, "Sample Person", "fake_presume_object")}

  it "should return resume text!" do
    expect(resume_classifier.text).to_not be_nil
  end

  it "separates tabbed words" do
    resume_classifier.instance_variable_set(:@text, "University of ChicagoJune 2008")

    resume_classifier.separate_tabbed_words

    expect(resume_classifier.text).to eq("University of Chicago,June 2008")
  end

  it "removes extra spaces" do
    resume_classifier.instance_variable_set(:@text, "University of Chicago      June 2008")

    resume_classifier.remove_extra_spaces

    expect(resume_classifier.text).to eq("University of Chicago  ,,,,June 2008")
  end

  it "removes blank lines" do
    resume_classifier.instance_variable_set("@lines", ["line with code", "          "])

    time = Benchmark.measure do
      resume_classifier.remove_blanks
    end
    puts time

    expect(resume_classifier.lines).to eq(["line with code"])
  end

  it "checks number of lines" do
    resume_classifier.instance_variable_set("@lines", ["line with code", "          "])

    time = Benchmark.measure do
      resume_classifier.number_of_lines
    end
    puts time

    expect(resume_classifier.number_of_lines).to eq(2)
  end

  it "splits text by new lines" do
    time = Benchmark.measure do
      resume_classifier.split_text
    end
    puts time

    expect(resume_classifier.lines).to_not be_nil
  end

  it "removes cities and dates from line" do
    resume_classifier.instance_variable_set("@line", "line with, Toronto, Ontario Sep 2009")

    expect(resume_classifier.remove_dates_and_cities).to eq("line with,  ")
  end

  it "counts words without date and city" do
    resume_classifier.instance_variable_set("@line", "line with, Toronto, Ontario Sep 2009")

    expect(resume_classifier.number_of_words).to eq(2)
  end

  it "sets number of lines" do
    resume_classifier.set_line_number(0)

    expect(resume_classifier.instance_variable_get(:@line_number)).to eq(0)
  end

  it "sets number of lines" do
    resume_classifier.set_line(0)

    puts resume_classifier.instance_variable_get(:@lines)

    expect(resume_classifier.instance_variable_get(:@line)).to eq("Professional Summary")
  end

  it "checks classifications" do
    resume_classifier.split_text

    expect(resume_classifier.number_of_lines).to be > 10

    resume_classifier.number_of_lines.times do |n|
      resume_classifier.set_line_number(n)

      expect(resume_classifier.instance_variable_get(:@line_number)).to eq(n)

      resume_classifier.set_line(n)
      time = Benchmark.measure do
        resume_classifier.check_classifications
      end
      puts time
    end
  end

  it "merges to classifide lines" do
    resume_classifier.split_text

    expect(resume_classifier.number_of_lines).to be > 10

    resume_classifier.number_of_lines.times do |n|
      resume_classifier.set_line_number(n)

      expect(resume_classifier.instance_variable_get(:@line_number)).to eq(n)

      resume_classifier.set_line(n)
      resume_classifier.check_classifications
      time = Benchmark.measure do
        resume_classifier.merge_to_classifide_lines

        expect(resume_classifier.classifide_lines.length).to eq(n + 1)
      end
      puts time
    end
  end

  describe '#classify' do
    context 'for profession lines' do
      it 'classifies professions that match the regex' do
        matching_profession_lines = [
          'Project Coordinator',
          'Junior Analyst',
          'Volunteer Coordinator',
          'Network Architect',
          'Data Governance Consultant',
          'Sr Account Executive',
          'Head of Talent Aquisition',
          'VP, Human Resources',
          'Vice President, Sales',
          'Director, Business Development',
          'Director of Business Development',
          'Customer Service Representative',
          'Customer Service Rep',
          'Contract Executive Recruiter',
          'Account Executive',
          'Independent Contractor',
          'Technical Sales Specialist'
        ]

        matching_profession_lines.each do |resume_text|
          subject = described_class.new(resume_text, "Sample Person", "fake_presume_object")

          subject.classify

          expect(subject.instance_variable_get(:@professions)).to eq(resume_text)
        end
      end
    end

    context 'for phone number lines' do
      it 'classifies phone numbers that match the regex' do
        matching_phone_lines = [
          '555-555-5555',
          '555 555 5555',
          '555.555.5555'
        ]

        matching_phone_lines.each do |resume_text|
          subject = described_class.new(resume_text, "Sample Person", "fake_presume_object")

          subject.classify

          expect(subject.instance_variable_get(:@phone)).to eq(resume_text)
        end
      end
    end
  end

=begin  		

	it "classifies lines by resume components" do

		time = Benchmark.measure do
			resume_classifier.classify
		end
  		puts time
		
	    expect(resume_classifier.classifide_lines[0].section).to eq("Professional Summary")
	    expect(resume_classifier.classifide_lines[1].phone).to be_nil
  	end

  	it "sorts classified lines into sections, headers, and bullets" do
		
  	end
=end

end
