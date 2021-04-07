function AUC=myplotroc_lmb(targets, outputs, class_labels)
    
    %figure();
    hold on;
    set(gca, 'LineStyleOrder', {'-', ':', '--', '-.'}); % different line styles
    for ii=1:length(class_labels)
       [tpr,fpr, T, AUCind] = perfcurve(targets,outputs, ii);
        plot(fpr, tpr)
        AUC{ii}=AUCind;
    end
    legend(class_labels);
end