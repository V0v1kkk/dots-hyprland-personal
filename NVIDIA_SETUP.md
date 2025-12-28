# NVIDIA RTX 3090 Setup для Hyprland

## Текущий статус

✅ **Установлено и настроено:**
- Драйвер NVIDIA: 590.48.01 (поддерживает explicit sync)
- Xwayland: 24.1.9 (поддерживает explicit sync)
- Kernel parameter: `nvidia-drm.modeset=1` (включен DRM)

## Рекомендуемые улучшения

### 1. Hardware Video Acceleration (VA-API)

Установи драйвер для аппаратного декодирования видео:

```bash
sudo pacman -S libva-nvidia-driver
```

Это решит проблемы с мерцанием в Electron-приложениях (Discord, VS Code, Chrome и т.д.)

### 2. Power Management (опционально)

Для улучшения suspend/resume стабильности, добавь kernel parameter в `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="... nvidia.NVreg_PreserveVideoMemoryAllocations=1"
```

Затем обнови grub:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 3. Проверь modprobe настройки

Создай/проверь файл `/etc/modprobe.d/nvidia.conf`:

```bash
sudo tee /etc/modprobe.d/nvidia.conf <<EOF
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF
```

Затем обнови initramfs:
```bash
sudo mkinitcpio -P
```

## Environment Variables

В `~/.config/hypr/custom/env.conf` уже настроено:

- `LIBVA_DRIVER_NAME=nvidia` - VA-API driver
- `__GLX_VENDOR_LIBRARY_NAME=nvidia` - OpenGL vendor
- `GBM_BACKEND=nvidia-drm` - GBM backend (критично для QuickShell)
- `WLR_NO_HARDWARE_CURSORS=1` - программный курсор (фикс для NVIDIA)
- `ELECTRON_OZONE_PLATFORM_HINT=auto` - нативный Wayland для Electron

## Применение изменений

1. Скопируй обновленный env.conf:
```bash
cp ~/.config/end4_dotfiles/dots/.config/hypr/custom/env.conf ~/.config/hypr/custom/env.conf
```

2. Перезапусти Hyprland (выход из сессии)

## Источники

- [Hyprland NVIDIA Wiki](https://wiki.hyprland.org/Nvidia/)
- NVIDIA Driver: 590.48.01
- Explicit Sync поддержка: ✅ (driver 555+, Xwayland 24.1+)
