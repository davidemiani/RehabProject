function uishadow(app,text)
% SHADOWONAPP displays a shadow on all the components of an uifigure.

% declaring shadow as persistent variable
persistent shadow

% validating inputs
narginchk(1,2)
nargoutchk(0,0);
if nargin==2
    mustBeCharacter(text)
else
    text = '';
end

% creating shadow if necessary
if isempty(shadow) || not(isvalid(shadow))
    shadow = uibutton(app.UIFigure,'Visible','off', ...
        'Position',[-5,-5,app.UIFigure.Position(3:4)+10], ...
        'Text',text,'FontColor',[1,1,1],'FontSize',25,'FontWeight','Bold', ...
        'BackgroundColor',[0,0,0],'Enable','off');
end

% shadowing or not
if strcmp(shadow.Visible,'off')
    shadow.Visible = 'on';
else
    shadow.Visible = 'off';
end

% making the shadow appear immediately
drawnow
    
end

