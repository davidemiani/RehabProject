function figCloseRequestFcn(obj,~,~)
obj.ExelFigure.Figure.Visible = 'off';
disconnect(obj)
clc
end