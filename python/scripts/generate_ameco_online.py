import cx_Oracle
import pandas as pd


class GenerateAmecoOnline:
    def __init__(self):
        self.ameco_df = pd.DataFrame()
        self.countries = None
        self.indicators = None

    def read_csv(self, filepath, chapter):
        df_from_csv = pd.read_csv(filepath + "AMECO{}.TXT".format(chapter),
                                  delimiter=";",
                                  header=0,
                                  index_col=[0, 1, 2, 3, 4]
                                  )
        df_from_csv = df_from_csv.iloc[:, :-1]
        df_from_csv["CHAPTER"] = chapter
        df_from_csv.set_index("CHAPTER", append=True, inplace=True)
        self.ameco_df = pd.concat([self.ameco_df, df_from_csv])

    def get_countries(self):
        self.countries = self.ameco_df.index.map(lambda x: x[0].split(".")[0]).unique()
        print(self.countries)

    def get_indicators(self):
        self.indicators = self.ameco_df.index.map(lambda x: ".".join([x[0].split(".")[5], x[0].split(".")[1],
                                                  x[0].split(".")[2], x[0].split(".")[3], x[0].split(".")[4]])).unique()
        print(self.indicators)


if __name__ == "__main__":
    generate_ameco_online = GenerateAmecoOnline()
    for i in range(1, 19):
        generate_ameco_online.read_csv("R:/Projects/fastop/ameco_input_files/", i)

    generate_ameco_online.get_countries()
    generate_ameco_online.get_indicators()
