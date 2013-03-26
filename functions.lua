-- License: GPL-3
-- Author: Christoffer Öjeling

printf = function(s,...)
            return tex.print(s:format(...))
         end


function readTSV (file)
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
        look[v[1]] = v[2]
    end
    return look
end


fmt = [[\fill[fill=%s] (%f\textwidth,0) rectangle (%f\textwidth,\gheight) node [midway] {%.0f\%%};]]

function generate(p1, p2)
    local assoc = associateCourses("kurskoder.tsv")
    local exams = readTSV("resultat.tsv")
    for _, v in ipairs(exams) do
        local date = v[1]
        if date >= p1 and date <= p2 then
            local code = v[2]
            local gradeU = tonumber(v[3])
            local grade3 = tonumber(v[4])
            local grade4 = tonumber(v[5])
            local grade5 = tonumber(v[6])
            local sum = gradeU + grade3 + grade4 + grade5

            tex.print([[\begin{minipage}{\textwidth}]])
            printf([[\kurs{%s %s}\par\smallskip]], code, assoc[code])

            tex.print([[\begin{tikzpicture}]])
            local sU = gradeU / sum
            local s3 = (gradeU + grade3) / sum
            local s4 = (gradeU + grade3 + grade4) / sum
            local mkfield = function(color, a, b, num)
                printf(fmt, color, a, b, num/sum*100)
            end

            mkfield("cfail", 0, sU, gradeU)
            mkfield("cthree", sU, s3, grade3)
            mkfield("cfour", s3, s4, grade4)
            mkfield("cfive", s4, 1, grade5)

            tex.print([[\draw (0,0) rectangle (\textwidth,\gheight);]])
            tex.print([[\end{tikzpicture}]])

            printf([[\par Totalt: %d  --- U: %d ~~~ 3: %d ~~~ 4: %d ~~~ 5: %d]]
                    , sum, gradeU, grade3, grade4, grade5)
           tex.print([[\end{minipage}\par\bigskip]])
        end
    end
end
