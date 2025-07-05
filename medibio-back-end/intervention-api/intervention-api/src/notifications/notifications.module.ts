import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Module({
  providers: [NotificationsService],
  exports: [NotificationsService], // Exporter pour utilisation dans d'autres modules
})
export class NotificationsModule {}