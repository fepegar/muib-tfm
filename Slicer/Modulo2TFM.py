import os
import unittest
import math
import numpy as np
from __main__ import vtk, qt, ctk, slicer
from slicer.ScriptedLoadableModule import *


INTRA_SKIN_NAME = 'Supine large', 'Output surface CT'
INTRA_TUMOR_NAME = 'Estimated tumor', 'Tumor in deformed MRI space'
INTRA_SEGMENTED_TUMOR_NAME = 'Tumor in supine position', 'Tumor segmented on CT'
PRE_SKIN_NAME = 'Prone surface', 'Output surface MR'
PRE_SEGMENTED_TUMOR_NAME = 'Tumor in prone position', 'Tumor in MRI space'
DEFORMED_SKIN_NAME = 'Deformed mesh', 'Deformed MR mesh'
TRANSFORM_NAME = 'Initialization transform', 'MRI to CT transform'


def p(s):
    print s

#
# Modulo2TFM
#
class Modulo2TFM(ScriptedLoadableModule):
    def __init__(self, parent):
        ScriptedLoadableModule.__init__(self, parent)
        self.parent.title = "Breast deformation visualization"
        self.parent.categories = ["TFM"]
        self.parent.dependencies = []
        self.parent.contributors = ["Fernando Perez-Garcia (fepegar@gmail.com)"]
        self.parent.helpText = """
        This is a scripted module used to visualize the results of the CLI module 
        Breast Deformation CLI
        """
        self.parent.acknowledgementText = """
        This module is part of a master's thesis at the group of 
        Biomedical Imaging Technologies of the Universidad Politecnica de Madrid
    	"""
        

#
# Modulo2TFMWidget
#
class Modulo2TFMWidget(ScriptedLoadableModuleWidget):

    def setup(self):
        ScriptedLoadableModuleWidget.setup(self)

        self.mr2ctTransformNode = Transform(TRANSFORM_NAME)
        self.moduleDir = self.getModuleDir()
        self.iconsDir = os.path.join(self.moduleDir, 'Resources', 'Icons')
        self.modelsMap = {}

        # Update scene button
        self.updateSceneButton = qt.QPushButton('Update scene')
        self.parent.layout().addWidget(self.updateSceneButton)
        self.updateSceneButton.clicked.connect(self.onUpdateScene)
        styleSheet = 'QPushButton {font: bold}'
        self.updateSceneButton.setStyleSheet(styleSheet)

        # Update scene button
        self.reloadDataButton = qt.QPushButton('Look for nodes')
        self.parent.layout().addWidget(self.reloadDataButton)
        self.reloadDataButton.clicked.connect(self.onReload)
        styleSheet = 'QPushButton {font: bold}'
        self.reloadDataButton.setStyleSheet(styleSheet)

        # Intraoperative models
        intraoperativeButton = ctk.ctkCollapsibleButton()
        intraoperativeButton.setChecked(False)
        intraoperativeButton.text = "Intraoperative visualization"
        intraoperativeButton.setLayout(qt.QVBoxLayout())
        self.parent.layout().addWidget(intraoperativeButton)

        self.modelsMap['intraSkin'] = Model('Skin', self,
                          expectedNames = INTRA_SKIN_NAME,
                          smooth = True,
                          smoothIterations = 2,
                          color = self.getAnatomyColor('skin'), # Bonito, no util
                          opacity = .8,
                          backfaceCulling = True,
                          render = True,
                          sliceIntersectionVisibility = True,
                          scalars = True)
        intraoperativeButton.layout().addWidget(self.modelsMap['intraSkin'].groupBox)

        self.modelsMap['intraTumor'] = Model('Estimated tumor', self,
                          expectedNames = INTRA_TUMOR_NAME,
                          smooth = True,
                          color = [1, 0, 0], # red
                          sliceIntersectionVisibility = True)
        intraoperativeButton.layout().addWidget(self.modelsMap['intraTumor'].groupBox)

        self.modelsMap['intraSegmentedTumor'] = Model('Segmented tumor', self,
                          expectedNames = INTRA_SEGMENTED_TUMOR_NAME,
                          smooth = True,
                          opacity = .4,
                          color = [0, 1, 0], # green
                          sliceIntersectionVisibility = True)
        intraoperativeButton.layout().addWidget(self.modelsMap['intraSegmentedTumor'].groupBox)

        

        
        # MR preoperative models
        preoperativeButton = ctk.ctkCollapsibleButton()
        preoperativeButton.setChecked(False)
        preoperativeButton.text = "Preoperative visualization"
        preoperativeButton.setLayout(qt.QVBoxLayout())
        self.parent.layout().addWidget(preoperativeButton)

        self.modelsMap['preSkin'] = Model('Skin', self,
                          expectedNames = PRE_SKIN_NAME,
                          smooth = True,
                          smoothIterations = 2,
                          color = [0, 0, 1], #blue #self.getAnatomyColor('skin'),
                          opacity = .8,
                          backfaceCulling = True,
                          transform = Transform(TRANSFORM_NAME),
                          visibleAtStart = True,
                          scalars = True)
        preoperativeButton.layout().addWidget(self.modelsMap['preSkin'].groupBox)

        self.modelsMap['preTumor'] = Model('Segmented tumor', self,
                          expectedNames = PRE_SEGMENTED_TUMOR_NAME,
                          smooth = True,
                          color = self.getAnatomyColor('tissue'), #green
                          transform = Transform(TRANSFORM_NAME),
                          visibleAtStart = True,
                          sliceIntersectionVisibility = True)
        preoperativeButton.layout().addWidget(self.modelsMap['preTumor'].groupBox)


        # Deformation
        deformationButton = ctk.ctkCollapsibleButton()
        deformationButton.setChecked(False)
        deformationButton.text = "Deformation visualization"
        deformationButton.setLayout(qt.QVBoxLayout())
        self.parent.layout().addWidget(deformationButton)

        self.modelsMap['deformedSkin'] = Model('Deformed skin', self,
                          expectedNames = DEFORMED_SKIN_NAME,
                          smooth = True,
                          smoothIterations = 1,
                          color = [1, 0, 0], # red  #self.getAnatomyColor('skin'),
                          opacity = .8,
                          backfaceCulling = True,
                          scalars = True,
                          visibleAtStart = False,
                          sliceIntersectionVisibility = True)
        deformationButton.layout().addWidget(self.modelsMap['deformedSkin'].groupBox)


        # Add vertical spacer
        self.layout.addStretch(1)
        if self.modelsMap['intraSkin'].hasNode():
            self.modelsMap['intraSkin'].center3DView()
        self.hideModels()
        self.onUpdateScene()

    def getModuleDir(self):
        moduleName = self.moduleName.lower()
        d = slicer.modules.__dict__
        moduleNode = d[moduleName]
        return os.path.dirname(moduleNode.path)

    def onUpdateScene(self):
        p('onUpdateScene')
        self.updateModels()
        if 'intraTumor' in self.modelsMap:
            if self.modelsMap['intraTumor'].hasNode():
                self.jumpToPoint(self.modelsMap['intraTumor'].getCenter())
        elif 'preTumor' in self.modelsMap:
            if self.modelsMap['preTumor'].hasNode():
                self.jumpToPoint(self.modelsMap['preTumor'].getCenter())

    def hideModels(self):
        modelsCollection = slicer.mrmlScene.GetNodesByClass('vtkMRMLModelNode')
        for i in range(modelsCollection.GetNumberOfItems()):
            modelNode = modelsCollection.GetItemAsObject(i)
            displayNode = modelNode.GetDisplayNode()
            displayNode.SetVisibility(False)
        
    def updateModels(self):
        for key, model in self.modelsMap.items():
            node = model.getNode()
            if node is not None:
                displayNode = node.GetDisplayNode()
                displayNode.SetColor(model.color)
                displayNode.SetOpacity(model.opacity)
                displayNode.SetVisibility(model.visibleCheckBox.checked)
                displayNode.SetSliceIntersectionVisibility(model.sliceIntersectionVisibility)
                if model.scalars:
                    displayNode.SetScalarVisibility(model.scalarsButton.checked)
                if model.backfaceCulling:
                    displayNode.SetBackfaceCulling(model.backfaceCullingCheckBox.checked)
                else:
                    displayNode.SetBackfaceCulling(False)
                if model.render:
                    pass
        
    def jumpToPoint(self, coords):
        """
        Jumps the slice view to a given point

        :param coords: Coordinates of the point to jump to
        """
        nodes = slicer.mrmlScene.GetNodesByClass('vtkMRMLSliceNode')
        for idx in range(nodes.GetNumberOfItems()):
            sliceNode=nodes.GetItemAsObject(idx)
            sliceNode.JumpSlice(0,0,0)
            sliceNode.JumpSlice(coords[0],coords[1],coords[2])
            sliceNode.JumpAllSlices(coords[0],coords[1],coords[2])

    def getAnatomyColor(self, name):
        lut = slicer.util.getNode('GenericAnatomyColors')
        color = [0,0,0,0]
        i = lut.GetColorIndexByName(name)
        lut.GetColor(i, color)
        return color[:3]


class Transform:
    def __init__(self, names):
        self.names = names
        for name in names:
            node = slicer.util.getNode(name)
            if node is not None:
                self.node = node
                break

    def getID(self):
        return self.getNode().GetID()

    def getNode(self):
        return self.node

    def getMatrix(self):
        vtkMatrix = vtk.vtkMatrix4x4()
        self.getNode().GetMatrixTransformToWorld(vtkMatrix)
        matrix = np.identity(4, np.float)
        for row in xrange(4):
            for col in xrange(4):
                matrix[row,col] = vtkMatrix.GetElement(row,col)
        return matrix


class Model:
    def __init__(self, name, widgetParent,
                       expectedNames = None,
                       smooth = False,
                       smoothIterations = 1,
                       transform = None,
                       scalars = False,
                       color = [.5, .5, .5],
                       opacity = 1,
                       backfaceCulling = False,
                       render = False,
                       visibleAtStart = True,
                       sliceIntersectionVisibility = False):
        self.name = name
        self.widgetParent = widgetParent
        self.expectedNames = expectedNames
        self.smooth = smooth
        self.smoothIterations = smoothIterations
        self.transform = transform
        self.scalars = scalars
        self.color = color
        self.opacity = opacity
        self.backfaceCulling = backfaceCulling
        self.render = render
        self.visibleAtStart = visibleAtStart
        self.sliceIntersectionVisibility = sliceIntersectionVisibility
        self.setup()

    def setup(self):
        self.groupBox = qt.QGroupBox(self.name)
        self.groupBox.setLayout(qt.QVBoxLayout())

        self.inputModelSelectorFrame = qt.QFrame()
        self.inputModelSelectorFrame.setLayout(qt.QHBoxLayout())
        self.groupBox.layout().addWidget(self.inputModelSelectorFrame)

        self.inputModelSelectorLabel = qt.QLabel("Input Model: ", self.inputModelSelectorFrame)
        self.inputModelSelectorLabel.setToolTip( "Select the input model for " + '"' + self.name + '"')
        self.inputModelSelectorFrame.layout().addWidget(self.inputModelSelectorLabel)

        self.inputModelSelector = slicer.qMRMLNodeComboBox(self.inputModelSelectorFrame)
        self.inputModelSelector.nodeTypes = ( ("vtkMRMLModelNode"), "" )
        self.inputModelSelector.selectNodeUponCreation = False
        self.inputModelSelector.addEnabled = False
        self.inputModelSelector.removeEnabled = True
        self.inputModelSelector.noneEnabled = True
        self.inputModelSelector.showHidden = False
        self.inputModelSelector.showChildNodeTypes = False
        self.inputModelSelector.currentNodeChanged.connect(self.widgetParent.updateModels)
        self.inputModelSelector.currentNodeChanged.connect(self.center3DView)
        if self.scalars:
            self.inputModelSelector.currentNodeChanged.connect(self.setScalars)
        self.inputModelSelector.setMRMLScene( slicer.mrmlScene )
        self.inputModelSelectorFrame.layout().addWidget(self.inputModelSelector)

        if self.expectedNames is not None:
            for name in self.expectedNames:
                n = slicer.util.getNode(name)
                if n is not None:
                    self.inputModelSelector.setCurrentNode(n)
                    break

        self.buttonsFrame = qt.QFrame()
        self.buttonsFrame.setLayout(qt.QHBoxLayout())
        self.groupBox.layout().addWidget(self.buttonsFrame)

        self.visibleCheckBox = qt.QCheckBox("Visible")
        self.buttonsFrame.layout().addWidget(self.visibleCheckBox)
        self.visibleCheckBox.toggled.connect(self.widgetParent.updateModels)
        self.visibleCheckBox.setChecked(True)
        if not self.visibleAtStart:
            self.visibleCheckBox.toggle()


        if self.backfaceCulling:
            self.backfaceCullingCheckBox = qt.QCheckBox("Backface culling")
            self.buttonsFrame.layout().addWidget(self.backfaceCullingCheckBox)
            self.backfaceCullingCheckBox.toggled.connect(self.widgetParent.updateModels)
            self.backfaceCullingCheckBox.setChecked(False)

        # if self.render:
        #     self.renderCheckBox = qt.QCheckBox("Volume rendering")
        #     self.buttonsFrame.layout().addWidget(self.renderCheckBox)
        #     self.renderCheckBox.toggled.connect(self.widgetParent.updateModels)
        #     self.renderCheckBox.setChecked(False)

        if self.transform:
            self.transformButton = qt.QCheckBox()
            icon = qt.QIcon(os.path.join(self.widgetParent.iconsDir, 'Transform.png'))
            self.transformButton.setIcon(icon)
            self.buttonsFrame.layout().addWidget(self.transformButton)
            self.transformButton.toggled.connect(self.onTransform)

        if self.scalars:
            self.scalarsButton = qt.QCheckBox()
            icon = qt.QIcon(os.path.join(self.widgetParent.iconsDir,'Scalars.png'))
            self.scalarsButton.setIcon(icon)
            self.buttonsFrame.layout().addWidget(self.scalarsButton)
            self.scalarsButton.toggled.connect(self.onScalars)
            self.setScalars()

        if self.smooth:
            self.smoothButton = qt.QPushButton('Smooth')
            self.buttonsFrame.layout().addWidget(self.smoothButton)
            self.smoothButton.clicked.connect(self.onSmooth)

        self.centerButton = qt.QPushButton('Center 3D')
        self.buttonsFrame.layout().addWidget(self.centerButton)
        self.centerButton.clicked.connect(self.onCenter3DView)
            

    def setScalars(self):
        if not self.hasDisplayNode():
            return
        displayNode = self.getNode().GetDisplayNode()
        displayNode.SetActiveScalarName('RGB')
        displayNode.SetAndObserveColorNodeID('vtkMRMLColorTableNodeLabels')
        displayNode.SetInterpolation(1)  # Gouraud
        displayNode.SetScalarRangeFlag(3)
        # displayNode.SetAndObserveColorNodeID(parulaNode.GetID())
        displayNode.SetScalarVisibility(False)

    def onScalars(self):
        if not self.hasDisplayNode():
            return
        displayNode = self.getDisplayNode()
        displayNode.SetActiveScalarName('RGB')
        displayNode.SetAndObserveColorNodeID('vtkMRMLColorTableNodeLabels')
        displayNode.SetInterpolation(1)  # Gouraud
        displayNode.SetScalarRangeFlag(3)
        displayNode.SetScalarVisibility(not displayNode.GetScalarVisibility())

    def onTransform(self):
        if not self.checkThatNodeExists():
            return
        t = self.getNode().GetTransformNodeID()
        if t is None:
            self.getNode().SetAndObserveTransformNodeID(self.transform.getID())
        else:
            self.getNode().SetAndObserveTransformNodeID(None)
        self.center3DView()

    def onCenter3DView(self):
        if self.checkThatNodeExists():
            self.center3DView()
            self.visibleCheckBox.setChecked(True)

    def checkThatNodeExists(self):
        if self.hasNode():
            return True
        else:
            box = qt.QMessageBox()
            box.critical(self.groupBox, 'Error', 'Please select a node for this model.')
            return False
        
    def center3DView(self):
        # Center 3D view around intraoperative skin model
        if self.getNode() is None:
            return False
        x,y,z = self.getCenter()
        layoutManager = slicer.app.layoutManager()
        threeDWidget = layoutManager.threeDWidget(0)
        threeDView = threeDWidget.threeDView()
        threeDView.setFocalPoint(x,y,z)

    def onSmooth(self):
        if not self.checkThatNodeExists():
            return
        p('Smoothing %s, iterations: %d' % (self.name, self.smoothIterations))
        n = self.getNode()
        surface = None
        if vtk.VTK_MAJOR_VERSION <= 5:
          surface = n.GetPolyData()
        else:
          surface = n.GetPolyDataConnection()
        smoothing = vtk.vtkSmoothPolyDataFilter()
        smoothing.SetBoundarySmoothing(True)
        smoothing.SetNumberOfIterations(self.smoothIterations)
        smoothing.SetRelaxationFactor(0.5)
        if vtk.VTK_MAJOR_VERSION <= 5:
            smoothing.SetInput(surface)
            smoothing.Update()
        else:
            smoothing.SetInputConnection(surface)
            surface = smoothing.GetOutputPort()
        if vtk.VTK_MAJOR_VERSION <= 5:
            n.SetAndObservePolyData(surface)
        else:
            n.SetPolyDataConnection(surface)

    def getNode(self):
        return self.inputModelSelector.currentNode()

    def getDisplayNode(self):
        if self.hasNode():
            return self.getNode().GetDisplayNode()

    def getCenter(self):
        if not self.checkThatNodeExists():
            return
        t = self.getNode().GetTransformNodeID()
        center = np.array(self.getNode().GetPolyData().GetCenter())
        if t is None:
            return center
        else:
            matrix = self.transform.getMatrix()
            transformedCenter = center + matrix[:3, 3]
            return transformedCenter

    def hasNode(self):
        return self.getNode() is not None

    def hasDisplayNode(self):
        if self.hasNode():
            return self.getNode().GetDisplayNode() is not None



    





