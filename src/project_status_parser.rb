require 'csv'

class ProjectStatusParser
  def parse_from_file(file_path)
    projects = []

    rows = CSV.read(file_path, row_sep: "\r\n")
    rows.each_with_index do |row, i|
      next if i == 0 || row[0].nil?

      projects.push({
        project_name: row[0],
        next_milestone: row[4],
        summary: row[9]
      })
    end

    projects
  end
end
