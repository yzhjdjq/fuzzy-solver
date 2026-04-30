import sys
import os
from pathlib import Path
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from controllers.rule_controller import RuleController

def main():
  app = QApplication(sys.argv)
  app.setStyle("Material")
  
  engine = QQmlApplicationEngine()
  
  controller = RuleController()
  engine.rootContext().setContextProperty("ruleController", controller)
  
  qml_file = Path(__file__).parent / "frontend" / "qml" / "main.qml"
  engine.load(QUrl.fromLocalFile(str(qml_file)))
  
  if not engine.rootObjects():
    sys.exit(-1)
  
  sys.exit(app.exec())

if __name__ == "__main__":
  main()