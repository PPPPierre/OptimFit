function obj = clearAll(obj, name)
    if nargin == 1
        % Ѱ������wd_main_window��'Tag'�д���^m_'�Ŀؼ�
        objs = findall(obj.wd_main_window, '-regexp', 'Tag', '^m_');
        set(objs, 'Visible', 'off');
    else
        % Ѱ������wd_main_window��'Tag'�д��������name�Ŀؼ�
        objs = findall(obj.wd_main_window, '-regexp', 'Tag', name); 
        set(objs, 'Visible', 'off');
    end
end