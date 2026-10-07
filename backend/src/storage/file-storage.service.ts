import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'node:crypto';
import { createReadStream, type ReadStream } from 'node:fs';
import { mkdir, rm, stat, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { notFound } from '../common/errors/api-exceptions';
import type { StorageConfig } from '../config/configuration';

/** A stored file's key: `<folder>/<uuid>.<ext>`, nothing else. */
const KEY_PATTERN = /^[a-z-]+\/[0-9a-f-]{36}\.(jpg|png|pdf)$/;

/**
 * Private files on local disk. Keys are generated here — never built from
 * user input — so a caller cannot write or read outside the uploads
 * directory. The directory must not be served by the web server: files
 * are reachable only through API routes that check who is asking.
 */
@Injectable()
export class FileStorageService {
  private readonly root: string;

  constructor(config: ConfigService) {
    this.root = resolve(config.get<StorageConfig>('storage')!.uploadsDir);
  }

  /** Writes [data] under [folder] and returns its storage key. */
  async save(
    folder: string,
    extension: 'jpg' | 'png' | 'pdf',
    data: Buffer,
  ): Promise<string> {
    const key = `${folder}/${randomUUID()}.${extension}`;
    await mkdir(join(this.root, folder), { recursive: true });
    await writeFile(this.pathOf(key), data, { flag: 'wx', mode: 0o600 });
    return key;
  }

  async open(key: string): Promise<ReadStream> {
    const path = this.pathOf(key);
    try {
      await stat(path);
    } catch {
      throw notFound('File not found.');
    }
    return createReadStream(path);
  }

  /** Best effort: used to undo writes when the database step fails. */
  async remove(key: string): Promise<void> {
    await rm(this.pathOf(key), { force: true });
  }

  private pathOf(key: string): string {
    if (!KEY_PATTERN.test(key)) {
      throw new Error(`Invalid storage key: ${key}`);
    }
    return join(this.root, key);
  }
}
