import os
import unittest
import math
import numpy as np
from __main__ import vtk, qt, ctk, slicer
from slicer.ScriptedLoadableModule import *


patientsID = [0, 3, 4, 5, 6, 9]
patientsDataDir = '/Users/fernando/Dropbox/MUIB/TFM/data/'
sourceFilesNames = 'MR_nipples.fcsv', 'Output surface MR.ply', \
                   'CT_nipples.fcsv', 'Supine large.ply', \
                   'MR_tumor.ply', 'CT_tumor.ply'
resultsFileNames = ['Deformed MR mesh.ply',
                    'MRI to CT transform.txt',
                    'Tumor in deformed MRI space.ply',
                    'Tumor in MRI space.ply',
                    'Tumor segmented on CT.ply']
methods = ['Symmetrize_Free_Centroid_Conformal', 
           'Normalize_Free_Centroid_Combinatorial',
           'Symmetrize_Free_Centroid_Combinatorial']
fiducials = ['CT_closestVertices.fcsv',
             'CT_deformation_fiducials.fcsv',
             'CT_initializationCenter.fcsv',
             'MR_closestVertices.fcsv',
             'MR_def_closestVertices.fcsv',
             'MR_deformation_fiducials.fcsv',
             'MR_initializationCenter.fcsv',
             'possibleTumors.fcsv']


class ResultadosTFM(ScriptedLoadableModule):
    def __init__(self, parent):
        ScriptedLoadableModule.__init__(self, parent)
        self.parent.title = "Resultados TFM"
        self.parent.categories = ["TFM"]
        self.parent.dependencies = []
        self.parent.contributors = ["Fernando Perez Garcia (UPM)"]
        self.parent.helpText = """
        Esto es helptext
        """
        self.parent.acknowledgementText = """
        Biomedical Imaging Technologies - 
        Escuela Tecnica Superior de Ingenieria de Telecomunicacion - 
        Universidad Politecnica de Madrid
    	""" # replace with organization, grant and thanks.


class ResultadosTFMWidget(ScriptedLoadableModuleWidget):

    def setup(self):
        ScriptedLoadableModuleWidget.setup(self)

        self.groupBox = qt.QGroupBox('Patient and method')
        self.groupBox.setLayout(qt.QHBoxLayout())
        self.parent.layout().addWidget(self.groupBox)


        self.groupBox.layout().addStretch()

        self.patientComboBox = qt.QComboBox()
        self.patientComboBox.addItems([str(n) for n in patientsID])
        self.patientComboBox.currentIndexChanged.connect(self.updateScene)
        self.groupBox.layout().addWidget(self.patientComboBox)

        self.groupBox.layout().addStretch()

        self.methodComboBox = qt.QComboBox()
        self.methodComboBox.addItems([str(n) for n in methods])
        self.methodComboBox.currentIndexChanged.connect(self.updateScene)
        self.groupBox.layout().addWidget(self.methodComboBox)

        self.groupBox.layout().addStretch()

        self.videoButton = qt.QPushButton('Video')
        self.videoButton.clicked.connect(self.onVideoButton)
        self.parent.layout().addWidget(self.videoButton)

        # Add vertical spacer
        self.layout.addStretch(1)

    def onVideoButton(self):
        TAKE_SCREENSHOT_DEFAULT_PATH = '/Users/fernando/Dropbox/MUIB/TFM/capturas/videosSlicer/' #slicer.app.extensionsInstallPath+os.sep
        TAKE_SCREENSHOT_DEFAULT_PREFIX = 'screenshot_'
        PITCHROLLYAWINCREMENT = 1
        YAWAMOUNT = 360

        lm = slicer.app.layoutManager()
        view = lm.threeDWidget(0).threeDView()
        view.setPitchRollYawIncrement(PITCHROLLYAWINCREMENT)
        view.yawDirection = view.YawLeft
        screenshot_counter=0
        for i in range(0,YAWAMOUNT,1):
            rw=view.renderWindow()
            wti=vtk.vtkWindowToImageFilter()
            wti.SetInput(rw)
            wti.Update()
            writer=vtk.vtkPNGWriter()
            filename = TAKE_SCREENSHOT_DEFAULT_PATH + TAKE_SCREENSHOT_DEFAULT_PREFIX + str(screenshot_counter).zfill(5) + '.png'
            screenshot_counter+=1
            print 'Written screenshot to: '+filename
            writer.SetFileName(filename)
            writer.SetInputConnection(wti.GetOutputPort())
            writer.Write()
            view.yaw()
            view.forceRender()

    def getPatientDir(self, patientID):
        return os.path.join(patientsDataDir, 'caso_%d' % patientID)

    def updateScene(self):
        patientID = int(self.patientComboBox.currentText)
        method = self.methodComboBox.currentText
        self.addPatientResults(patientID, method)

    def addPatientSource(self, patientID):
        patientDir = self.getPatientDir(patientID)
        sourceDir = os.path.join(patientDir, 'mrml', 'source')
        for name in sourceFilesNames:
            filePath = os.path.join(sourceDir, name)
            if '.ply' in filePath:
                slicer.util.loadModel(filePath)
            elif '.fcsv' in filePath:
                slicer.util.loadMarkupsFiducialList(filePath)

    def addPatientResults(self, patientID, method):
        self.ensureModuleWidget()
        slicer.mrmlScene.Clear(0)
        self.addPatientSource(patientID)
        methodDir = os.path.join(self.getPatientDir(patientID), 'mrml', 'results', method)
        modelsDir = os.path.join(methodDir, 'models')
        fiducialsDir = os.path.join(methodDir, 'fiducials')
        for name in resultsFileNames:
            filePath = os.path.join(modelsDir, name)
            print 'Trying to add', filePath
            if '.ply' in filePath:
                slicer.util.loadModel(filePath)
            elif '.txt' in filePath:
                slicer.util.loadTransform(filePath)
        # for name in fiducials:
        #     filePath = os.path.join(fiducialsDir, name)
        #     slicer.util.loadMarkupsFiducialList(filePath)
        w = slicer.modules.Modulo2TFMWidget
        w.onReload()

    def ensureModuleWidget(self):
        if not hasattr(slicer.modules, 'Modulo2TFMWidget'):
            slicer.util.selectModule('Modulo2TFM') # just to create the widget of the module
            slicer.util.selectModule('ResultadosTFM')



