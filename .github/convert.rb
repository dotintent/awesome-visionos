README = 'README.md'
CONTENTS = 'contents.json'

def get_json()
    require 'json'
    JSON.parse(File.read CONTENTS)
end

def output_projects(proj, id)
  o = ''
  proj.select {|p| p['category']==id }
    .sort_by {|k,v| k['title'].downcase}
    .each do |p|
    o << "- [#{p['title']}](#{p['homepage']}) - #{p['description']}\n"
  end
  o
end

def output_content_category(c, indent)
  toc = "\n"

  for i in 1..indent
    toc << '#'
  end

  toc << " #{c['title']}\n"
  toc << "_#{c['description']}_\n" unless c['description'].nil?
  #toc << "[back to top](#readme) \n" if indent>2
  toc << "\n"

  toc
end

def output_content(j)
  toc = ''

  projects = j['projects']

  parents, children = j['categories'].partition { |c| c['parent'].nil? }
  parents.each do |c|
    id = c['id'].gsub(/[^a-zA-Z]/, '').downcase
    toc << output_content_category(c, 2)
    toc << output_projects(projects, id)

    children.sort_by {|k,v| k['id']}
      .select {|c| c['parent']==id}.each do |c|
      child_id = c['id']

      toc << output_content_category(c, 3)
      toc << output_projects(projects, child_id)

      children.sort_by {|k,v| k['id']}
        .select {|c| c['parent']==child_id}.each do |c|
        child_id = c['id']

        toc << output_content_category(c, 4)
        toc << output_projects(projects, c['id'])

        children.sort_by {|k,v| k['id']}
          .select {|c| c['parent']==child_id}.each do |c|
          child_id = c['id']

          toc << output_content_category(c, 5)
          toc << output_projects(projects, c['id'])
        end 
      end
    end
  end

  toc
end

def output_header(j)
  header       = j['header']
  title        = j['title']
  badge        = j['badge']
  num_projects = j['projects'].count

  o = "<!--lint disable awesome-heading-->\n"
  o << "# " + title +" "+ badge
  o << header + "\n"
  o << "\n\n"
  o << output_table(num_projects)

  o
end

def output_contributing(j)
  o = "\n\n## Contributing\n\n"
  o << j['header_contributing']
  o
end

def output_table(num_projects)
  o = "![](https://img.shields.io/badge/Contents-#{num_projects}-green)"
  o << " ![](https://img.shields.io/github/last-commit/dotintent/awesome-visionos/main)"
  o
end

def output_toc(j)
  toc = "\n\n## Contents\n\n"

  parents, children = j['categories'].partition { |c| c['parent'].nil? }
  parents.each do |c|
    id = c['id']
    toc << "- [#{c['title']}](##{id})\n"

    children.sort_by {|k,v| k['id']}
      .select {|c| c['parent']==id}.each do |c|
      child_id = c['id']
      toc << "  - [#{c['title']}](##{child_id})\n"

      children.sort_by {|k,v| k['id']}
        .select {|c| c['parent']==child_id}.each do |c|
        child_id = c['id']
        toc << "    - [#{c['title']}](##{c['id']})\n"

        children.sort_by {|k,v| k['id']}
          .select {|c| c['parent']==child_id}.each do |c|
          toc << "      - [#{c['title']}](##{c['id']})\n"
        end
      end
    end
  end

  toc
end

def write_readme(j, filename)
    output = output_header(j)
    output << output_toc(j)
    output << output_content(j)
    output << output_contributing(j)

    File.open(filename, 'w') { |f| f.write output}
    puts "Wrote #{filename} :)"
end

j = get_json()
write_readme(j, README)
