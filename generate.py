__author__ = "Christoffer Öjeling"
__license__ = "GPLv3"

from collections import defaultdict
import xlrd

def main():
    dtekCourses = get_course_codes("kurskoder.tsv")
    programs, exams, courses = get_exam_results('Statistik_over_kursresultat.xlsx')

    for exret, results in exams.items():
        courseIdx, examType, date = exret
        if courses[courseIdx] in dtekCourses:
            tot = sum(results.get(x, 0) for x in ['U', '3', '4', '5'])
            # To skip re-exams. (buggy output) 15 arbitrarily selected
            if tot < 15:
                continue
            s = '\t'.join(
                [ date
                , courses[courseIdx]
                , str(results.get('U', 0))
                , str(results.get('3', 0))
                , str(results.get('4', 0))
                , str(results.get('5', 0))
                ])
            print(s)


class ReferenceDict:
    def __init__(self):
        self.store = []
        self.meta = []
        self.reverse = {}

    def add(self, key):
        if key in self.reverse:
            return self.reverse[key]
        else:
            self.meta.append(None)
            self.store.append(key)
            self.reverse[key] = len(self.store)-1
            return len(self.store)-1

    def __getitem__(self, index):
        return self.store[index]


# Get from the TSV file
def get_course_codes(path):
    return frozenset(line.split('\t')[0] for line in open(path, 'r'))


# Get results from the monster xlsx file
def get_exam_results(path):
    workbook = xlrd.open_workbook(path)
    sheets = workbook.sheet_names()

    exams = defaultdict(dict)

    # The programs of Chalmers eg "MPALG"
    programs = ReferenceDict()

    # The courses of Chalmers eg "DIT123"
    courses = ReferenceDict()

    # skip first sheet
    for sheet in workbook.sheets()[1:]:
        #first row description
        for i in range(1, sheet.nrows):
            row = sheet.row(i)
            courseCode = row[0].value
            courseName = row[1].value
            programCode = row[2].value
            programName = row[3].value
            examType = row[5].value
            hp = row[6].value
            date = row[7].value
            grade = row[8].value
            n = int(row[9].value)

            programIdx = programs.add(programCode)
            programs.meta[programIdx] = (programName,)

            courseIdx = courses.add(courseCode)
            courses.meta[courseIdx] = (programIdx, courseName)

            exams[(courseIdx, examType, date)][grade] = n

    return (programs, exams, courses)


if __name__ == '__main__':
    main()
