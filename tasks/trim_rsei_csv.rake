desc "trims the gigantic rsei csv for just the parishes we want"
task :trim_rsei_csv do
  require 'csv'
  re = /^22(005|007|033|037|047|051|057|063|071|075|077|087|089|093|095|103|105|121|125)/
  out = []
  CSV.foreach("/Volumes/AL\'S\ DRIVE/la_lrn/micro2017_2017.csv") do |row|
    if row[3] =~ re
      out << row
    end
  end
  CSV.open("/Volumes/AL\'S\ DRIVE/la_lrn/micro_2017_2017_trimmed.csv", "w") do |csv|
    out.each do |r|
      csv << r
    end
  end
end


### cat micro2017_2017.csv | csvgrep -c 4 -r "^22(005|007|033|037|047|051|057|063|071|075|077|087|089|093|095|103|105|121|125)" -H > micro2017_louisiana.csv