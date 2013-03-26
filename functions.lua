-- License: GPL-3
-- Author: Christoffer Öjeling

printf = function(s,...)
            return tex.print(s:format(...))
         end


function readTSV (file, fieldnames)
    local fp = assert(io.open(file, "r"))
    local tsv = {}
    for line in fp:lines() do
        local row = {}
        for value in line:gmatch("[^\t]+") do
            table.insert(row, value)
        end
        if #row > 0 then
            table.insert(tsv, row)
        end
    end
    return tsv
end


function associateCourses (file)
    local tsv = readTSV(file)
    local look = {}
    for x, v in ipairs(tsv) do
        look[v[1]] = {["owner"] = v[2], ["name"] = v[3]}
    end
    return look
end


fmt = [[\fill[fill=%s] (%f\textwidth,0) rectangle (%f\textwidth,\gheight) node [midway] {%.0f\%%};]]

function generate(p1, p2)
    local assoc = associateCourses("kurskoder.tsv")
    local exams = readTSV("resultat.tsv")
    local program = readTSV("program.tsv")

    res = {}
    reversemap = {}
    for i, v in ipairs(program) do
        reversemap[v[1]] = i
        res[i] = {}
    end


    for _, v in ipairs(exams) do
        local date = v[1]
        if date >= p1 and date <= p2 then
            local entry = {}
            entry.code = v[2]
            entry.name = assoc[entry.code].name
            entry.date = date
            entry.gradeU = tonumber(v[3])
            entry.grade3 = tonumber(v[4])
            entry.grade4 = tonumber(v[5])
            entry.grade5 = tonumber(v[6])
            local idx = assert(reversemap[assoc[entry.code].owner]
                , "Kurskod \"" .. assoc[entry.code].owner .. "\" hittades inte" )
            table.insert(res[idx], entry)
        end
    end

    for i, owner in ipairs(res) do
        if #owner > 0 then
            local programname = program[i][2]
            printf([[\section*{%s}]], programname)
            for _, course in ipairs(res[i]) do
                graphCourse(course)
            end
        end
    end
end


function graphCourse(entry)
    local sum = entry.gradeU + entry.grade3 + entry.grade4 + entry.grade5

    tex.print([[\begin{minipage}{\textwidth}]])
    printf([[\kurs{%s %s}\par\smallskip]], entry.code, entry.name)

    tex.print([[\begin{tikzpicture}]])
    local sU = entry.gradeU / sum
    local s3 = (entry.gradeU + entry.grade3) / sum
    local s4 = (entry.gradeU + entry.grade3 + entry.grade4) / sum
    local mkfield = function(color, a, b, num)
        printf(fmt, color, a, b, num/sum*100)
    end

    mkfield("cfail", 0, sU, entry.gradeU)
    mkfield("cthree", sU, s3, entry.grade3)
    mkfield("cfour", s3, s4, entry.grade4)
    mkfield("cfive", s4, 1, entry.grade5)

    tex.print([[\draw (0,0) rectangle (\textwidth,\gheight);]])
    tex.print([[\end{tikzpicture}]])

    printf([[\par Totalt: %d  --- U: %d ~~~ 3: %d ~~~ 4: %d ~~~ 5: %d]]
            , sum, entry.gradeU, entry.grade3, entry.grade4, entry.grade5)
   tex.print([[\end{minipage}\bigbreak]])
end
