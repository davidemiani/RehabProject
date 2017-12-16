function uishadow(app,text)
% comment needed.

% declaring shadow as persistent variable
persistent shadow

% validating inputs
narginchk(1,2)
nargoutchk(0,0);
if nargin==2
    mustBeCharacter(text)
    enable = true;
else
    text = '';
    enable = false;
end

% creating shadow if necessary
if isempty(shadow) || not(isvalid(shadow))
    shadow = uibutton(app.UIFigure,'Visible','off', ...
        'Position',[-5,-5,app.UIFigure.Position(3:4)+10], ...
        'FontColor',[1,1,1],'FontSize',25,'FontWeight','Bold', ...
        'BackgroundColor',[0,0,0],'Enable','off');
end

% setting text
shadow.Text = text;

% shadowing or de-shadowing
if enable
    shadow.Visible = 'on';
else
    shadow.Visible = 'off';
    delete(shadow)
end

% making the shadow appear immediately
drawnow
    
end

