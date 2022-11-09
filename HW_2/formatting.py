from sklearn.datasets import load_svmlight_file
import pandas as pd
import argparse
import time

parser = argparse.ArgumentParser(description='file_name')
parser.add_argument('txt_file_name', type=str, help='txt_file_name')
parser.add_argument('csv_file_name', type=str, help='csv_file_name')
args = parser.parse_args()
txt_file_name = args.txt_file_name
csv_file_name = args.csv_file_name


def get_data():
    data = load_svmlight_file(txt_file_name)
    return data[0], data[1]


try:
    # without sleep python doesnt see created txt file. It was't long time after it real creation. 
    time.sleep(1)
    X, y = get_data()
    X = X.toarray()
    df = pd.DataFrame(X)
    new_columns = []
    for col in df.columns:
        new_columns.append(col + 1)
    df['target'] = y
    new_columns.append('target')
    df.to_csv(csv_file_name, index=False, header=new_columns)
except Exception as exc:
    print(f'WARNING! {txt_file_name} reading error! Dataset {csv_file_name} is empty!')
    df = pd.DataFrame()
    df.to_csv(csv_file_name)


