import torch
from torch import nn
from torch.nn import functional as F
from torch import optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import torchmetrics
import pytorch_lightning as pl
from pytorch_lightning.callbacks import Callback


class MyPrintingCallback(Callback):
    def on_train_start(self, trainer, pl_module):
        print('Starting to train!')
    
    def on_train_end(self, trainer, pl_module):
        print('Training is done!')


class CNNLightning(pl.LightningModule):
    def __init__(self, in_channels=1, out_channels=10):
        super().__init__()
        self.train_acc = torchmetrics.Accuracy(task='multiclass', num_classes=10)
        self.conv1 = nn.Conv2d(
            in_channels=in_channels,
            out_channels=out_channels,
            kernel_size=3,
            stride=1,
            padding=1)
        self.pool = nn.MaxPool2d(kernel_size=2, stride=2)
        self.conv2 = nn.Conv2d(
            in_channels=out_channels,
            out_channels=16,
            kernel_size=3,
            stride=1,
            padding=1)
        self.fc1 = nn.Linear(7 * 7 * 16, 10)
        
    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = x.reshape(x.size(0), -1)
        scores = self.fc1(x)
        return scores
        
    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)  # Inputs passed to the self method indirectly invoke the forward method.
        loss = F.cross_entropy(y_hat, y)
        batch_acc = self.train_acc(y_hat, y)
        self.log('train_acc_step', batch_acc, on_step=True, on_epoch=True, prog_bar=True, logger=True)
        return loss
    
    def training_epoch_end(self, outputs):
        self.log('train_acc_epoch', self.train_acc.compute())
        self.train_acc.reset()
    
    def configure_optimizers(self):
        return optim.AdamW(self.parameters(), lr=3e-4)

    def validation_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        self.log('val_loss', loss, on_step=True)
        
    def test_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        self.log('test_loss', loss, on_step=True)
        
    def predict_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        return y_hat


device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Hyperparameters
num_epochs = 1
batch_size = 64
learning_rate = 3e-4
in_channels = 1
out_channels = 10

# Load data
train_loader = DataLoader(
    datasets.MNIST(
        root='../../data',
        train=True,
        download=True,
        transform=transforms.ToTensor()),
    batch_size=batch_size,
    shuffle=True,
    num_workers=8)

test_loader = DataLoader(
    datasets.MNIST(
        root='../../data',
        train=False,
        download=True,
        transform=transforms.ToTensor()),
    batch_size=batch_size,
    shuffle=False,
    num_workers=8)

# Initialize model
model = CNNLightning(in_channels=in_channels, out_channels=out_channels).to(device)

# Train model
trainer = pl.Trainer(
                     max_epochs=num_epochs,
                     accelerator='gpu',
                     devices=[1],
                     callbacks=[MyPrintingCallback(),
                                ],#pl.callbacks.QuantizationAwareTraining()],
                     auto_lr_find=True,
                     auto_scale_batch_size=True,
                     precision=16  # Mixed precision. Makes training faster.
                     )
trainer.fit(model=model, train_dataloaders=train_loader)

# Test model
#trainer.test(model, dataloaders=train_loader)
trainer.test(model, test_loader)

# Save model
#torch.save(model.state_dict(), 'model.ckpt')

# Load model
#model.load_state_dict(torch.load('model.ckpt'))
