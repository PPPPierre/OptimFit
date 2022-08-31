function obj = disableAll(obj, name)
    wd_cell = {'popupmenu', 'pushbutton', 'slider', 'edit'};
    if nargin == 1
        % Ѱ������wd_main_window��'Tag'�д���^m_'�Ŀؼ�
        objs = findall(obj.wd_main_window, '-regexp', 'Tag', '^m_');
        for i = 1:length(objs)
            if strcmp(objs(i).Type, 'uicontrol')
                if ismember(objs(i).Style, wd_cell) 
                    set(objs(i), 'Enable', 'off');
                end
            end
        end
        
    else
        % Ѱ������wd_main_window��'Tag'�д��������name�Ŀؼ�
        objs = findall(obj.wd_main_window, '-regexp', 'Tag', name); 
        for i = 1:length(objs)
            if strcmp(objs(i).Type, 'uicontrol')
                if ismember(objs(i).Style, wd_cell) 
                    set(objs(i), 'Enable', 'off');
                end
            end
        end
    end
end