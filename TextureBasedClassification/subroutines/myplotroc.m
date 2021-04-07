function myplotroc(target, output, class_labels)
    [tpr,fpr,~] = roc(target,output)
    figure();
    hold on;
    set(gca, 'LineStyleOrder', {'-', ':', '--', '-.'}); % different line styles
    for ii=1:length(class_labels)
        plot(fpr{ii}, tpr{ii})
    end
    legend(class_labels);
end