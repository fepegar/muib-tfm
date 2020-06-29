function largest = largestregion(mask)
    stats = regionprops(mask, 'Area','PixelIdxList');
    [~, labelLargest] = max([stats.Area]);
    idx = stats(labelLargest).PixelIdxList;
    largest = false(size(mask));
    largest(idx) = true;
end