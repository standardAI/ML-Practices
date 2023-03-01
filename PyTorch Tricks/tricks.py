# Make batch_size 1 and
data, targets = next(iter(train_loader))
# Overfit on a single batch; then make batch_size to another number


# make model.eval() in check_accuracy


# Don't forget optimizer.zero_grad() in train function


# Don't use Softmax with CrossEntropyLoss
# nn.BCEWithLogitsLoss() loss function which automatically applies 
# the Sigmoid activation.
# If you are using nn.BCELoss, the output should use torch.sigmoid 
# as the activation function.


# Don't use view for permute
x = torch.tensor([[1,2,3], [4,5,6]])
x.view(3, 2)  # Wrong!
x.permute(1, 0)  # Correct!


# Don't use wrong data augmentations
# Albumentations is faster than torchvision.transforms


# Shuffle train loader; but not on time-series data


# Don't forget Normalization


# When training RNNs:
loss.backward()
torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1)
optimizer.step()
